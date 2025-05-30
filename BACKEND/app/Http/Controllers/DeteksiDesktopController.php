<?php

namespace App\Http\Controllers;
use Illuminate\Support\Facades\Http;
use Illuminate\Http\Request;
use App\Models\DeteksiPenyakit;
use Illuminate\Support\Facades\Auth;

class DeteksiDesktopController extends Controller
{
    public function index()
    {
        $user = Auth::user();

        // Ambil data DeteksiPenyakit hanya milik user tersebut
        $deteksiPenyakit = DeteksiPenyakit::where('user_id', $user->id)->get();
        
        return view('deteksi.index', compact('deteksiPenyakit'));
    }
        
    public function create()
    {
        return view('deteksi.form');
    }
    
    public function show($id)
    {
        $deteksi = DeteksiPenyakit::findOrFail($id);
        
        // Periksa apakah deteksi ini milik user yang login
        if (Auth::id() !== $deteksi->user_id) {
            return redirect()->route('deteksi.index')->with('error', 'Anda tidak memiliki akses ke data ini');
        }
        
        return view('deteksi.result', compact('deteksi'));
    }
    
    public function indexlatest()
    {
        $deteksiPenyakit = DeteksiPenyakit::latest()->first();
        
        if (!$deteksiPenyakit) {
            return redirect()->route('deteksi.index')->with('info', 'Belum ada data deteksi');
        }
        
        return redirect()->route('deteksi.show', ['id' => $deteksiPenyakit->id]);
    }
    
    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'nama' => 'required',
                'pregnancies' => 'required|integer',
                'age' => 'required|integer',
                'bmi' => 'required|numeric',
                'blood_pressure' => 'required|numeric',
                'bs' => 'required|numeric',
                'skin_thickness' => 'nullable|numeric',
                'sex' => 'nullable|integer',
                'current_smoker' => 'nullable|integer',
                'cigs_per_day' => 'nullable|integer',
                'bp_meds' => 'nullable|integer',
                'systolic_bp' => 'nullable|numeric',
                'diastolic_bp' => 'nullable|numeric',
                'heart_rate' => 'nullable|numeric',
                'body_temp' => 'nullable|numeric',
            ]);

            // Dapatkan user dari auth
            $user = Auth::user();
            if (!$user) {
                return redirect()->route('login')->with('error', 'Anda harus login terlebih dahulu');
            }

            // Simpan ke database
            $deteksi = DeteksiPenyakit::create([
                'user_id' => $user->id,
                'bidan_id' => $user->id,
                'nama' => $request->nama,
                'pregnancies' => $request->pregnancies,
                'age' => $request->age,
                'bmi' => $request->bmi,
                'blood_pressure' => $request->blood_pressure,
                'bs' => $request->bs,
                'skin_thickness' => $request->skin_thickness,
                'sex' => $request->sex,
                'current_smoker' => $request->current_smoker,
                'cigs_per_day' => $request->cigs_per_day,
                'bp_meds' => $request->bp_meds,
                'systolic_bp' => $request->systolic_bp,
                'diastolic_bp' => $request->diastolic_bp,
                'heart_rate' => $request->heart_rate,
                'body_temp' => $request->body_temp,
            ]);

            // Format data sesuai dengan yang bekerja di Postman
            $requestData = [
                'diabetes' => [
                    'Pregnancies' => (int)$request->pregnancies,
                    'BS' => (float)$request->bs,
                    'BloodPressure' => (float)$request->blood_pressure,
                    'SkinThickness' => (float)($request->skin_thickness ?? 0),
                    'BMI' => (float)$request->bmi,
                    'Age' => (int)$request->age
                ],
                'hypertension' => [
                    'sex' => (int)($request->sex ?? 0),
                    'Age' => (int)$request->age,
                    'currentSmoker' => (int)($request->current_smoker ?? 0),
                    'cigsPerDay' => (int)($request->cigs_per_day ?? 0),
                    'BPMeds' => (int)($request->bp_meds ?? 0),
                    'diabetes' => (int)($request->bs > 140 ? 1 : 0),
                    'SystolicBP' => (float)($request->systolic_bp ?? 120),
                    'DiastolicBP' => (float)($request->diastolic_bp ?? 80),
                    'BMI' => (float)$request->bmi,
                    'Heartrate' => (float)($request->heart_rate ?? 70),
                    'BS' => (float)$request->bs
                ],
                'maternal_health' => [
                    'Age' => (int)$request->age,
                    'SystolicBP' => (float)($request->systolic_bp ?? 120),
                    'DiastolicBP' => (float)($request->diastolic_bp ?? 80),
                    'BS' => (float)$request->bs,
                    'BodyTemp' => (float)($request->body_temp ?? 36.6),
                    'HeartRate' => (float)($request->heart_rate ?? 70)
                ]
            ];

            // Log the request for debugging
            \Log::info('Sending request to ML API:', $requestData);

            // Kirim ke model ML dengan headers
            $response = Http::post('https://sehatiml-production.up.railway.app/predictdeteksi', $requestData);

            // Debug response
            \Log::info('API Response Status: ' . $response->status());
            \Log::info('API Response Body: ' . $response->body());

            // Parse response
            $prediction = $response->json();
            
            // Check if we have valid prediction results
            if (isset($prediction['diabetes_prediction']) && 
                isset($prediction['hypertension_prediction']) && 
                isset($prediction['maternal_health_prediction'])) {
                
                // Update hasil prediksi
                $deteksi->update([
                    'diabetes_prediction' => $prediction['diabetes_prediction'],
                    'hypertension_prediction' => $prediction['hypertension_prediction'],
                    'maternal_health_prediction' => $prediction['maternal_health_prediction'],
                ]);

                return redirect()->route('deteksi.show', $deteksi->deteksi_id)
                    ->with('success', 'Data berhasil disimpan dan prediksi telah diterima');
            } 
            // Check if we have error messages
            else if (isset($prediction['diabetes_error']) || 
                    isset($prediction['hypertension_error']) || 
                    isset($prediction['maternal_health_error'])) {
                
                \Log::error('ML API returned errors: ' . json_encode($prediction));
                
                return redirect()->route('deteksi.show', $deteksi->deteksi_id)
                    ->with('warning', 'Data disimpan tetapi layanan prediksi mengalami masalah teknis. Silakan coba lagi nanti.');
            }
            // Unexpected response format
            else {
                \Log::error('Unexpected response format from ML API: ' . json_encode($prediction));
                
                return redirect()->route('deteksi.show', $deteksi->deteksi_id)
                    ->with('warning', 'Data disimpan tetapi format respon prediksi tidak sesuai. Silakan hubungi administrator.');
            }
                    
        } catch (\Exception $e) {
            \Log::error('Error in DeteksiPenyakit store: ' . $e->getMessage());
            return redirect()->back()
                ->with('error', 'Terjadi kesalahan: ' . $e->getMessage())
                ->withInput();
        }
    }
    
    
    public function deleteAll()
    {
        // Hanya hapus data milik user yang login
        DeteksiPenyakit::where('user_id', Auth::id())->delete(); 
        
        return redirect()->route('deteksi.index')
            ->with('success', 'Semua data berhasil dihapus');
    }
   
    public function destroy($id)
    {
        $deteksi = DeteksiPenyakit::find($id);

        if (!$deteksi) {
            return redirect()->route('deteksi.index')
                ->with('error', 'Data tidak ditemukan');
        }
        
        // Pastikan yang menghapus adalah pemilik data
        if (Auth::id() !== $deteksi->user_id) {
            return redirect()->route('deteksi.index')
                ->with('error', 'Anda tidak memiliki akses untuk menghapus data ini');
        }

        $deteksi->delete();

        return redirect()->route('deteksi.index')
            ->with('success', 'Data berhasil dihapus');
    }
}