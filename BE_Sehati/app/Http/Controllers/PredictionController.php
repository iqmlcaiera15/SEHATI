<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Prediction;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Exception;

class PredictionController extends Controller
{
    private $FLASK_API_URL = "http://127.0.0.1:5000/predict"; // URL Flask API

    public function index()
    {
        $predictions = Prediction::all();

        return response()->json([
            'status' => 'success',
            'data' => $predictions
        ], 200);
    }

    public function show($id)
    {
        $prediction = Prediction::find($id);

        if (!$prediction) {
            return response()->json([
                'status' => 'error',
                'message' => 'Prediksi tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => $prediction
        ], 200);
    }

    public function store(Request $request)
    {
        try {
            // 🔹 Validasi input dari user
            $validated = $request->validate([
                'usia_ibu' => 'required|integer|min:15|max:50',
                'tekanan_darah' => 'required|string|in:normal,rendah,tinggi',
                'riwayat_persalinan' => 'required|string|in:tidak ada,normal,caesar',
                'posisi_janin' => 'required|string|in:normal,lintang,sungsang',
                'riwayat_kesehatan_ibu' => 'nullable|string',
                'kondisi_kesehatan_janin' => 'nullable|string'
            ]);

            // 🔹 Siapkan data untuk dikirim ke Flask
            $requestData = [
                'usia_ibu' => (int) $validated['usia_ibu'],
                'tekanan_darah' => strtolower($validated['tekanan_darah']),
                'riwayat_persalinan' => strtolower($validated['riwayat_persalinan']),
                'posisi_janin' => strtolower($validated['posisi_janin']),
                'riwayat_kesehatan_ibu' => $validated['riwayat_kesehatan_ibu'] ?? 'normal', // Tidak lowercase
                'kondisi_kesehatan_janin' => $validated['kondisi_kesehatan_janin'] ?? 'Normal' // Tidak lowercase
            ];

            Log::info('📩 Data yang dikirim ke Flask:', $requestData);

            // 🔹 Kirim POST ke Flask API
            $response = Http::withHeaders([
                'Content-Type' => 'application/json',
                'Accept' => 'application/json'
            ])->post($this->FLASK_API_URL, $requestData);

            if ($response->failed()) {
                Log::error('❌ Flask API gagal merespons.', ['response' => $response->body()]);
                return response()->json([
                    'status' => 'error',
                    'message' => 'Gagal mendapatkan prediksi dari Flask API',
                    'details' => $response->json()
                ], 500);
            }

            $flaskResponse = $response->json();
            Log::info('✅ Respons dari Flask API:', $flaskResponse);

            // 🔹 Ambil data dari respons Flask
            $status = $flaskResponse['status'] ?? null;
            $message = $flaskResponse['message'] ?? null;
            $hasilPrediksi = $flaskResponse['hasil_prediksi'] ?? null;

            if (empty($status) || empty($message) || empty($hasilPrediksi)) {
                Log::error('❌ Respons Flask API tidak lengkap.', $flaskResponse);
                return response()->json([
                    'status' => 'error',
                    'message' => 'Respons Flask API tidak valid',
                    'details' => $flaskResponse
                ], 500);
            }

            // 🔹 Simpan hasil ke database
            $prediction = Prediction::create(array_merge($validated, [
                'metode_persalinan' => $hasilPrediksi
            ]));

            return response()->json([
                'status' => 'success',
                'message' => $message,
                'hasil_prediksi' => $hasilPrediksi,
                'data' => $prediction
            ], 201);

        } catch (Exception $e) {
            Log::error('❌ Terjadi Exception:', ['error' => $e->getMessage()]);
            return response()->json([
                'status' => 'error',
                'message' => 'Terjadi kesalahan saat memproses prediksi',
                'details' => $e->getMessage()
            ], 500);
        }
    }
}
