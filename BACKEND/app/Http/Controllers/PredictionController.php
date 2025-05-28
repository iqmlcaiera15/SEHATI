<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Prediction;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Http;

class PredictionController extends Controller
{
    public function index()
    {
        $predictions = Prediction::latest()->get();

        return response()->json([
            'status' => 'success',
            'data' => $predictions
        ]);
    }

    public function show($id)
    {
        $prediction = Prediction::find($id);

        if (!$prediction) {
            return response()->json([
                'status' => 'error',
                'message' => 'Data tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => $prediction
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'usia_ibu' => 'required|integer|min:15|max:50',
            'tekanan_darah' => 'required|in:normal,rendah,tinggi',
            'riwayat_persalinan' => 'required|in:tidak ada,normal,caesar',
            'posisi_janin' => 'required|in:normal,lintang,sungsang',
            'riwayat_kesehatan_ibu' => 'nullable|string',
            'kondisi_kesehatan_janin' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $dataToSend = [
                'usia_ibu' => (int) $request->usia_ibu,
                'tekanan_darah' => strtolower($request->tekanan_darah),
                'riwayat_persalinan' => strtolower($request->riwayat_persalinan),
                'posisi_janin' => strtolower($request->posisi_janin),
                'riwayat_kesehatan_ibu' => $request->riwayat_kesehatan_ibu ?? 'normal',
                'kondisi_kesehatan_janin' => $request->kondisi_kesehatan_janin ?? 'normal',
            ];

            // Kirim ke Flask API
            $flaskUrl = 'https://sehatimlprediksi-production.up.railway.app/predict';
            $response = Http::post($flaskUrl, $dataToSend);

            if ($response->failed()) {
                $status = $response->status();
                $body = $response->body();
                throw new \Exception("Gagal memanggil Flask API. Status: $status. Respons: $body");
            }

            $result = $response->json();
            $hasil = $result['hasil_prediksi'] ?? null;
            $faktor = $result['faktor'] ?? '-';

            if (!$hasil) {
                throw new \Exception("Respons Flask tidak lengkap: " . json_encode($result));
            }

            $prediction = Prediction::create(array_merge(
                $dataToSend,
                [
                    'metode_persalinan' => $hasil,
                    'faktor' => $faktor
                ]
            ));

            return response()->json([
                'status' => 'success',
                'message' => $result['message'] ?? 'Prediksi berhasil',
                'hasil_prediksi' => $hasil,
                'faktor' => $faktor,
                'data' => $prediction
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Terjadi kesalahan saat prediksi',
                'error_detail' => $e->getMessage()
            ], 500);
        }
    }

    public function deletebyID($id)
    {
        $prediction = Prediction::find($id);

        if (!$prediction) {
            return response()->json([
                'status' => 'error',
                'message' => 'Data tidak ditemukan'
            ], 404);
        }

        $prediction->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Riwayat prediksi berhasil dihapus'
        ]);
    }
}
