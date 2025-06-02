<?php

namespace App\Http\Controllers;

use App\Models\Prediction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Http;

class PredictionController extends Controller
{
    // GET /api/predictions
    public function index(Request $request)
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $query = Prediction::latest();

        // Filter prediksi hanya milik user login (user_id)
        $query->where('user_id', $user->id);

        // Optional filter
        if ($request->filled('method')) {
            $query->where('metode_persalinan', $request->method);
        }
        if ($request->filled('date')) {
            $query->whereDate('created_at', $request->date);
        }

        $predictions = $query->get();

        return response()->json([
            'success' => true,
            'data' => $predictions
        ], 200);
    }

    // POST /api/predictions
    public function store(Request $request)
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $validator = Validator::make($request->all(), [
            'usia_ibu' => 'required|integer|min:15|max:50',
            'tekanan_darah' => 'required|in:normal,rendah,tinggi',
            'riwayat_persalinan' => 'required|in:tidak ada,normal,caesar',
            'posisi_janin' => 'required|in:normal,lintang,sungsang',
            'riwayat_kesehatan_ibu' => 'required|string',
            'kondisi_kesehatan_janin' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first()
            ], 422);
        }

        try {
            $dataToSend = [
                'usia_ibu' => (int) $request->usia_ibu,
                'tekanan_darah' => strtolower($request->tekanan_darah),
                'riwayat_persalinan' => strtolower($request->riwayat_persalinan),
                'posisi_janin' => strtolower($request->posisi_janin),
                'riwayat_kesehatan_ibu' => strtolower($request->riwayat_kesehatan_ibu),
                'kondisi_kesehatan_janin' => strtolower($request->kondisi_kesehatan_janin),
            ];

            $flaskUrl = 'https://sehatimlprediksi-production.up.railway.app/predict';
            $response = Http::post($flaskUrl, $dataToSend);

            if ($response->failed()) {
                $msg = "Gagal memanggil Flask API. Status: {$response->status()}. Respons: {$response->body()}";
                return response()->json([
                    'success' => false,
                    'message' => $msg
                ], $response->status());
            }

            $result = $response->json();
            $hasil = $result['hasil_prediksi'] ?? null;
            $faktor = $result['faktor'] ?? '-';

            if (!$hasil) {
                $msg = "Respons Flask tidak lengkap: " . json_encode($result);
                return response()->json([
                    'success' => false,
                    'message' => $msg
                ], 500);
            }

            $prediction = Prediction::create([
                'usia_ibu' => $dataToSend['usia_ibu'],
                'tekanan_darah' => $dataToSend['tekanan_darah'],
                'riwayat_persalinan' => $dataToSend['riwayat_persalinan'],
                'posisi_janin' => $dataToSend['posisi_janin'],
                'riwayat_kesehatan_ibu' => $dataToSend['riwayat_kesehatan_ibu'],
                'kondisi_kesehatan_janin' => $dataToSend['kondisi_kesehatan_janin'],
                'metode_persalinan' => $hasil,
                'faktor' => $faktor,
                'user_id' => $user->id,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Berhasil melakukan prediksi.',
                'hasil_prediksi' => $hasil,
                'faktor' => $faktor,
                'data' => $prediction
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat prediksi: ' . $e->getMessage()
            ], 500);
        }
    }

    // DELETE /api/predictions/{id}
    public function deletebyID($id, Request $request)
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $prediction = Prediction::find($id);

        if (!$prediction) {
            return response()->json(['success' => false, 'message' => 'Data tidak ditemukan'], 404);
        }

        // Pastikan hanya owner yang boleh hapus
        if ($user->id !== $prediction->user_id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $prediction->delete();

        return response()->json(['success' => true, 'message' => 'Riwayat prediksi berhasil dihapus']);
    }

    // GET /api/predictions/{id}
    public function result($id, Request $request)
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $prediction = Prediction::find($id);

        if (!$prediction) {
            return response()->json(['success' => false, 'message' => 'Data tidak ditemukan'], 404);
        }

        // Pastikan hanya owner yang boleh akses
        if ($user->id !== $prediction->user_id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $prediction
        ]);
    }
}
