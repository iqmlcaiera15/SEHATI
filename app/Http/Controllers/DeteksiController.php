<?php

namespace App\Http\Controllers;
use Illuminate\Support\Facades\Http;
use Illuminate\Http\Request;
use App\Models\DeteksiPenyakit;

class DeteksiController extends Controller
{
    public function index()
    {
        $DeteksiPenyakit = DeteksiPenyakit::all();

        return response()->json([
            'DeteksiPenyakit' => $DeteksiPenyakit
        ]);
    }
    

    public function store(Request $request)
    {   try {
            $request->validate([
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
        
            // Simpan ke database
            $deteksi = DeteksiPenyakit::create([
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
            
            // Kirim data ke API ML Railway
            $response = Http::post('https://sehatiml-production.up.railway.app/predict', [
                'diabetes' => [
                    'Pregnancies' => $request->pregnancies ?? 0,
                    'BS' => $request->bs,
                    'BloodPressure' => $request->blood_pressure,
                    'SkinThickness' => $request->skin_thickness ?? 0,
                    'BMI' => $request->bmi,
                    'Age' => $request->umur
                ],
                'hypertension' => [
                    'sex' => $request->sex,
                    'Age' => $request->umur,
                    'currentSmoker' => $request->current_smoker,
                    'cigsPerDay' => $request->cigs_per_day,
                    'BPMeds' => $request->bp_meds,
                    'diabetes' => $request->bs > 140 ? 1 : 0,
                    'SystolicBP' => $request->systolic_bp,
                    'DiastolicBP' => $request->diastolic_bp,
                    'BMI' => $request->bmi,
                    'Heartrate' => $request->heart_rate,
                    'BS' => $request->bs
                ],
                'maternal_health' => [
                    'Age' => $request->umur,
                    'SystolicBP' => $request->systolic_bp,
                    'DiastolicBP' => $request->diastolic_bp,
                    'BS' => $request->bs,
                    'BodyTemp' => $request->body_temp,
                    'HeartRate' => $request->heart_rate
                ]
        
            ]);
    
        // Ambil hasil prediksi dari API ML
        $prediction = $response->json();
    
        // Update database dengan hasil prediksi
        $deteksi->update([
            'diabetes_prediction' => $prediction['diabetes_prediction'],
            'hypertension_prediction' => $prediction['hypertension_prediction'],
            'maternal_health_prediction' => $prediction['maternal_health_prediction']
        ]);
    
        return response()->json([
            'status' => 'success',
            'message' => 'Data successfully stored and ML prediction retrieved',
            'prediction' => $prediction
        ], 201);

    } catch (\Exception $e) {
        \Log::error('Error in DeteksiPenyakit store function: ' . $e->getMessage());
        return response()->json([
            'status' => 'error',
            'message' => 'Internal Server Error',
            'error' => $e->getMessage()
        ], 500);
    }
}


    

    public function deleteAll()
    {
        DeteksiPenyakit::truncate(); 
        return response()->json([
            'status' => 'success',
            'message' => 'All data deleted successfully'
        ], 200);
    }

   
    public function deleteById($id)
    {
        $deteksi = DeteksiPenyakit::find($id);

        if (!$deteksi) {
            return response()->json([
                'status' => 'error',
                'message' => 'Data not found'
            ], 404);
        }

        $deteksi->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Data deleted successfully'
        ], 200);
    }




}





