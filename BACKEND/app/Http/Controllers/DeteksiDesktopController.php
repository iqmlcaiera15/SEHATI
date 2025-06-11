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
                'nama' => 'required|string|max:255',
                'pregnancies' => 'required|integer|min:0|max:20',
                'age' => 'required|integer|min:15|max:100',
                'bmi' => 'required|numeric|min:10|max:50',
                'bs' => 'required|numeric|min:50|max:500',
                'skin_thickness' => 'nullable|numeric|min:0|max:100',
                'current_smoker' => 'nullable|integer|in:0,1',
                'cigs_per_day' => 'nullable|integer|min:0|max:100',
                'bp_meds' => 'nullable|integer|in:0,1',
                'systolic_bp' => 'required|numeric|min:80|max:250',
                'diastolic_bp' => 'required|numeric|min:50|max:150',
                'heart_rate' => 'nullable|numeric|min:40|max:200',
                'body_temp' => 'nullable|numeric|min:35|max:42',
            ], [
                'nama.required' => 'Nama lengkap wajib diisi',
                'pregnancies.required' => 'Jumlah kehamilan wajib diisi',
                'pregnancies.min' => 'Jumlah kehamilan tidak boleh kurang dari 0',
                'pregnancies.max' => 'Jumlah kehamilan tidak boleh lebih dari 20',
                'age.required' => 'Umur wajib diisi',
                'age.min' => 'Umur minimal 15 tahun',
                'age.max' => 'Umur maksimal 100 tahun',
                'bmi.required' => 'BMI wajib diisi',
                'bmi.min' => 'BMI tidak boleh kurang dari 10',
                'bmi.max' => 'BMI tidak boleh lebih dari 50',
                'bs.required' => 'Gula darah wajib diisi',
                'bs.min' => 'Nilai gula darah tidak valid',
                'bs.max' => 'Nilai gula darah terlalu tinggi',
                'systolic_bp.required' => 'Tekanan sistolik wajib diisi',
                'systolic_bp.min' => 'Tekanan sistolik minimal 80 mmHg',
                'systolic_bp.max' => 'Tekanan sistolik maksimal 250 mmHg',
                'diastolic_bp.required' => 'Tekanan diastolik wajib diisi',
                'diastolic_bp.min' => 'Tekanan diastolik minimal 50 mmHg',
                'diastolic_bp.max' => 'Tekanan diastolik maksimal 150 mmHg',
            ]);

            // Dapatkan user dari auth
            $user = Auth::user();
            if (!$user) {
                return redirect()->route('login')->with('error', 'Anda harus login terlebih dahulu');
            }

            // Hitung MAP (Mean Arterial Pressure) dari tekanan sistolik dan diastolik
            $systolic = (float)$request->systolic_bp;
            $diastolic = (float)$request->diastolic_bp;
            $map = ($systolic + (2 * $diastolic)) / 3;

            // Set default values untuk field opsional
            $skinThickness = $request->skin_thickness ?? 0;
            $heartRate = $request->heart_rate ?? 70;
            $bodyTemp = $request->body_temp ?? 36.6;
            $currentSmoker = $request->current_smoker ?? 0;
            $cigsPerDay = ($currentSmoker == 1) ? ($request->cigs_per_day ?? 0) : 0;
            $bpMeds = $request->bp_meds ?? 0;

            // Simpan ke database
            $deteksi = DeteksiPenyakit::create([
                'user_id' => $user->id,
                'bidan_id' => $user->id,
                'nama' => $request->nama,
                'pregnancies' => $request->pregnancies,
                'age' => $request->age,
                'bmi' => $request->bmi,
                'blood_pressure' => round($map, 2), // MAP yang sudah dihitung
                'bs' => $request->bs,
                'skin_thickness' => $skinThickness,
                'sex' => 0, // Hardcoded sebagai perempuan
                'current_smoker' => $currentSmoker,
                'cigs_per_day' => $cigsPerDay,
                'bp_meds' => $bpMeds,
                'systolic_bp' => $request->systolic_bp,
                'diastolic_bp' => $request->diastolic_bp,
                'heart_rate' => $heartRate,
                'body_temp' => $bodyTemp,
            ]);

            // Format data sesuai dengan API ML
            $requestData = [
                'diabetes' => [
                    'Pregnancies' => (int)$request->pregnancies,
                    'BS' => (float)$request->bs,
                    'BloodPressure' => round($map, 2), // Menggunakan MAP yang dihitung
                    'SkinThickness' => (float)$skinThickness,
                    'BMI' => (float)$request->bmi,
                    'Age' => (int)$request->age
                ],
                'hypertension' => [
                    'sex' => 0, // Hardcoded sebagai perempuan
                    'Age' => (int)$request->age,
                    'currentSmoker' => (int)$currentSmoker,
                    'cigsPerDay' => (int)$cigsPerDay,
                    'BPMeds' => (int)$bpMeds,
                    'diabetes' => (int)($request->bs > 140 ? 1 : 0), // Auto-detect diabetes dari gula darah
                    'SystolicBP' => (float)$request->systolic_bp,
                    'DiastolicBP' => (float)$request->diastolic_bp,
                    'BMI' => (float)$request->bmi,
                    'Heartrate' => (float)$heartRate,
                    'BS' => (float)$request->bs
                ],
                'maternal_health' => [
                    'Age' => (int)$request->age,
                    'SystolicBP' => (float)$request->systolic_bp,
                    'DiastolicBP' => (float)$request->diastolic_bp,
                    'BS' => (float)$request->bs,
                    'BodyTemp' => (float)$bodyTemp,
                    'HeartRate' => (float)$heartRate
                ]
            ];

            // Log the request for debugging
            \Log::info('Sending request to ML API:', [
                'user_id' => $user->id,
                'deteksi_id' => $deteksi->deteksi_id,
                'calculated_map' => round($map, 2),
                'request_data' => $requestData
            ]);

            // Kirim ke model ML
            $response = Http::timeout(30)->post('https://sehatiml-production.up.railway.app/predictdeteksi', $requestData);

            // Debug response
            \Log::info('API Response Status: ' . $response->status());
            \Log::info('API Response Body: ' . $response->body());

            // Parse response
            if ($response->successful()) {
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

                    // Success message dengan informasi tambahan
                    $successMessage = 'Data berhasil disimpan dan prediksi telah diterima. ';
                    $successMessage .= 'MAP (Mean Arterial Pressure) dihitung: ' . round($map, 1) . ' mmHg';

                    return redirect()->route('deteksi.show', $deteksi->deteksi_id)
                        ->with('success', $successMessage);
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
            } else {
                // HTTP error
                \Log::error('HTTP Error from ML API: ' . $response->status() . ' - ' . $response->body());
                
                return redirect()->route('deteksi.show', $deteksi->deteksi_id)
                    ->with('warning', 'Data disimpan tetapi layanan prediksi tidak dapat diakses. Status: ' . $response->status());
            }
                        
        } catch (\Illuminate\Validation\ValidationException $e) {
            // Validation errors
            return redirect()->back()
                ->withErrors($e->validator)
                ->withInput()
                ->with('error', 'Mohon periksa kembali data yang dimasukkan');
                
        } catch (\Exception $e) {
            \Log::error('Error in DeteksiPenyakit store: ' . $e->getMessage(), [
                'user_id' => Auth::id(),
                'request_data' => $request->all(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return redirect()->back()
                ->with('error', 'Terjadi kesalahan sistem. Silakan coba lagi atau hubungi administrator.')
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