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
            // --- MODIFIED VALIDATION ---
            // Validasi input baru: tinggi_badan dan berat_badan
            // Validasi BMI tetap ada karena dihitung oleh JS dan dikirim via hidden input
            $validated = $request->validate([
                'nama' => 'required|string|max:255',
                'pregnancies' => 'required|integer|min:0|max:20',
                'age' => 'required|integer|min:15|max:100',
                'tinggi_badan' => 'required|numeric|min:100|max:250', // Validasi tinggi badan (cm)
                'berat_badan' => 'required|numeric|min:30|max:200',  // Validasi berat badan (kg)
                'bmi' => 'nullable|numeric|min:10|max:50', // Validasi hasil kalkulasi BMI
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
                'age.required' => 'Umur wajib diisi',
                'age.min' => 'Umur minimal 15 tahun',
                'tinggi_badan.required' => 'Tinggi badan wajib diisi.',
                'berat_badan.required' => 'Berat badan wajib diisi.',
                'bmi.required' => 'BMI tidak dapat dihitung. Pastikan tinggi dan berat badan terisi.',
                'bs.required' => 'Gula darah wajib diisi',
                'bs.min' => 'Nilai gula darah tidak valid',
                'systolic_bp.required' => 'Tekanan sistolik wajib diisi',
                'diastolic_bp.required' => 'Tekanan diastolik wajib diisi',
            ]);

            $user = Auth::user();
            if (!$user) {
                return redirect()->route('login')->with('error', 'Anda harus login terlebih dahulu');
            }

            // Hitung MAP (Mean Arterial Pressure)
            $systolic = (float)$request->systolic_bp;
            $diastolic = (float)$request->diastolic_bp;
            $map = ($systolic + (2 * $diastolic)) / 3;

            // --- NEW: Konversi Gula Darah dari mg/dL ke mmol/L ---
            $bs_mgdl = (float)$request->bs;
            $bs_mmol = $bs_mgdl / 18.0182; // Faktor konversi

            // Set default values untuk field opsional
            $skinThickness = $request->skin_thickness ?? 0;
            $heartRate = $request->heart_rate ?? 70;
            $bodyTemp = $request->body_temp ?? 36.6;
            $currentSmoker = $request->current_smoker ?? 0;
            $cigsPerDay = ($currentSmoker == 1) ? ($request->cigs_per_day ?? 0) : 0;
            $bpMeds = $request->bp_meds ?? 0;

            // Simpan ke database
            // Nilai BMI sudah dihitung di frontend dan dikirim melalui $request->bmi
            // Nilai BS disimpan dalam format asli (mg/dL)
            $deteksi = DeteksiPenyakit::create([
                'user_id' => $user->id,
                'bidan_id' => $user->id,
                'nama' => $request->nama,
                'pregnancies' => $request->pregnancies,
                'age' => $request->age,
                'bmi' => $request->bmi, // BMI dari hidden input
                'blood_pressure' => round($map, 2),
                'bs' => $request->bs, // Simpan sebagai mg/dL
                'skin_thickness' => $skinThickness,
                'sex' => 0,
                'current_smoker' => $currentSmoker,
                'cigs_per_day' => $cigsPerDay,
                'bp_meds' => $bpMeds,
                'systolic_bp' => $request->systolic_bp,
                'diastolic_bp' => $request->diastolic_bp,
                'heart_rate' => $heartRate,
                'body_temp' => $bodyTemp,
            ]);

            // --- MODIFIED: Format data sesuai dengan API ML ---
            $requestData = [
                'diabetes' => [ // Menggunakan mg/dL
                    'Pregnancies' => (int)$request->pregnancies,
                    'BS' => $bs_mgdl,
                    'BloodPressure' => round($map, 2),
                    'SkinThickness' => (float)$skinThickness,
                    'BMI' => (float)$request->bmi,
                    'Age' => (int)$request->age
                ],
                'hypertension' => [ // Menggunakan mmol/L
                    'sex' => 0,
                    'Age' => (int)$request->age,
                    'currentSmoker' => (int)$currentSmoker,
                    'cigsPerDay' => (int)$cigsPerDay,
                    'BPMeds' => (int)$bpMeds,
                    'diabetes' => (int)($bs_mgdl > 140 ? 1 : 0),
                    'SystolicBP' => (float)$request->systolic_bp,
                    'DiastolicBP' => (float)$request->diastolic_bp,
                    'BMI' => (float)$request->bmi,
                    'Heartrate' => (float)$heartRate,
                    'BS' => round($bs_mmol, 2) // --- Kirim dalam format mmol/L ---
                ],
                'maternal_health' => [ // Menggunakan mg/dL
                    'Age' => (int)$request->age,
                    'SystolicBP' => (float)$request->systolic_bp,
                    'DiastolicBP' => (float)$request->diastolic_bp,
                    'BS' => $bs_mgdl,
                    'BodyTemp' => (float)$bodyTemp,
                    'HeartRate' => (float)$heartRate
                ]
            ];
            
            \Log::info('Sending request to ML API:', [
                'user_id' => $user->id,
                'deteksi_id' => $deteksi->id, // Menggunakan id yang benar
                'request_data' => $requestData
            ]);

            $response = Http::timeout(30)->post('https://sehatiml-production.up.railway.app/predictdeteksi', $requestData);

            \Log::info('API Response Status: ' . $response->status());
            \Log::info('API Response Body: ' . $response->body());

            if ($response->successful()) {
                $prediction = $response->json();
                
                if (isset($prediction['diabetes_prediction']) && isset($prediction['hypertension_prediction']) && isset($prediction['maternal_health_prediction'])) {
                    $deteksi->update([
                        'diabetes_prediction' => $prediction['diabetes_prediction'],
                        'hypertension_prediction' => $prediction['hypertension_prediction'],
                        'maternal_health_prediction' => $prediction['maternal_health_prediction'],
                    ]);

                    return redirect()->route('deteksi.show', $deteksi->id) // Menggunakan id yang benar
                        ->with('success', 'Data berhasil disimpan dan prediksi telah diterima.');
                } else {
                    \Log::error('Unexpected response format from ML API: ' . json_encode($prediction));
                    return redirect()->route('deteksi.show', $deteksi->id)
                        ->with('warning', 'Data disimpan tetapi format respon prediksi tidak sesuai. Silakan hubungi administrator.');
                }
            } else {
                \Log::error('HTTP Error from ML API: ' . $response->status() . ' - ' . $response->body());
                return redirect()->route('deteksi.show', $deteksi->id)
                    ->with('warning', 'Data disimpan tetapi layanan prediksi tidak dapat diakses. Status: ' . $response->status());
            }

        } catch (\Illuminate\Validation\ValidationException $e) {
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
    
    // ... (deleteAll and destroy methods remain the same) ...
    public function deleteAll()
    {
    DeteksiPenyakit::where('user_id', Auth::id())->delete(); 
        return redirect()->route('deteksi.index')
        ->with('success', 'Semua data berhasil dihapus');
    }

    public function destroy($id)
    {
    $deteksi = DeteksiPenyakit::find($id);
    if (!$deteksi) {
        return redirect()->route('deteksi.index')->with('error', 'Data tidak ditemukan');
        }
    if (Auth::id() !== $deteksi->user_id) {
        return redirect()->route('deteksi.index')->with('error', 'Anda tidak memiliki akses untuk menghapus data ini');
        }
        $deteksi->delete();
        return redirect()->route('deteksi.index')->with('success', 'Data berhasil dihapus');
    }
}