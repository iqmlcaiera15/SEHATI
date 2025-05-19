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
    
            // Kirim ke model ML
            $response = Http::post('https://sehatiml-production.up.railway.app/predictdeteksi', [
                'diabetes' => [
                    'Pregnancies' => $request->pregnancies ?? 0,
                    'BS' => $request->bs,
                    'BloodPressure' => $request->blood_pressure,
                    'SkinThickness' => $request->skin_thickness ?? 0,
                    'BMI' => $request->bmi,
                    'Age' => $request->age,
                ],
                'hypertension' => [
                    'sex' => $request->sex,
                    'Age' => $request->age,
                    'currentSmoker' => $request->current_smoker,
                    'cigsPerDay' => $request->cigs_per_day,
                    'BPMeds' => $request->bp_meds,
                    'diabetes' => $request->bs > 140 ? 1 : 0,
                    'SystolicBP' => $request->systolic_bp,
                    'DiastolicBP' => $request->diastolic_bp,
                    'BMI' => $request->bmi,
                    'Heartrate' => $request->heart_rate,
                    'BS' => $request->bs,
                ],
                'maternal_health' => [
                    'Age' => $request->age,
                    'SystolicBP' => $request->systolic_bp,
                    'DiastolicBP' => $request->diastolic_bp,
                    'BS' => $request->bs,
                    'BodyTemp' => $request->body_temp,
                    'HeartRate' => $request->heart_rate,
                ],
            ]);
    
            $prediction = $response->json();
            
            // Update hasil prediksi
            $deteksi->update([
                'diabetes_prediction' => $prediction['diabetes_prediction'],
                'hypertension_prediction' => $prediction['hypertension_prediction'],
                'maternal_health_prediction' => $prediction['maternal_health_prediction'],
            ]);
    
            return redirect()->route('deteksi.show', $deteksi->id)
                ->with('success', 'Data berhasil disimpan dan prediksi telah diterima');
                
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