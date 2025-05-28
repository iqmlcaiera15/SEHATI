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
        return response()->json(Prediction::all());
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
                "status" => "error",
                "errors" => $validator->errors()
            ], 422);
        }

        try {
            $user = $request->user(); // optional: check if using auth
            $dataInput = [
                'usia_ibu' => (int) $request->usia_ibu,
                'tekanan_darah' => strtolower($request->tekanan_darah),
                'riwayat_persalinan' => strtolower($request->riwayat_persalinan),
                'posisi_janin' => strtolower($request->posisi_janin),
                'riwayat_kesehatan_ibu' => $request->riwayat_kesehatan_ibu ?? 'normal',
                'kondisi_kesehatan_janin' => $request->kondisi_kesehatan_janin ?? 'normal',
            ];

            // Kirim data ke Flask API
            $response = Http::post('https://sehatimlpredict-production.up.railway.app/predict', $dataInput);

            if ($response->failed()) {
                throw new \Exception("Gagal memanggil Flask API. Status: " . $response->status());
            }

            $result = $response->json();
            $hasil = $result['hasil_prediksi'] ?? null;
            $faktor = $result['faktor'] ?? '-';

            if (!$hasil) {
                throw new \Exception("Respons Flask tidak lengkap: " . json_encode($result));
            }

            // Simpan ke DB
            $prediction = Prediction::create(array_merge(
                $dataInput,
                [
                    'metode_persalinan' => $hasil,
                    'faktor' => $faktor,
                    'user_id' => $user?->id, // bisa null
                ]
            ));

            return response()->json([
                "status" => "success",
                "message" => $result['message'] ?? "Prediksi berhasil",
                "data" => $prediction
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                "status" => "error",
                "message" => "Terjadi kesalahan saat memproses prediksi",
                "error_detail" => $e->getMessage()
            ], 500);
        }
    }

    public function show($id)
    {
        $prediction = Prediction::find($id);

        if (!$prediction) {
            return response()->json([
                "status" => "error",
                "message" => "Data tidak ditemukan"
            ], 404);
        }

        return response()->json([
            "status" => "success",
            "data" => $prediction
        ]);
    }

    public function deletebyID($id)
    {
        $prediction = Prediction::find($id);

        if (!$prediction) {
            return response()->json([
                "status" => "error",
                "message" => "Data tidak ditemukan"
            ], 404);
        }

        $prediction->delete();

        return response()->json([
            "status" => "success",
            "message" => "History prediksi berhasil dihapus"
        ]);
    }

    private function categorizeUmur($umur)
    {
        if ($umur <= 30) return 0;
        elseif ($umur >= 31 && $umur <= 35) return 1;
        elseif ($umur >= 36 && $umur <= 40) return 2;
        elseif ($umur >= 41 && $umur <= 45) return 3;
        elseif ($umur >= 46 && $umur <= 50) return 4;
        else return null; // umur di luar jangkauan
    }

    private function convertToNumber($field, $value)
    {
        $mapping = [
            'merasa_sedih' => ['Tidak' => 0, 'Ya' => 1, 'Kadang-kadang' => 2],
            'mudah_tersinggung' => ['Tidak' => 0, 'Ya' => 1, 'Kadang-kadang' => 2],
            'masalah_tidur' => ['Tidak' => 0, 'Ya' => 1, 'Dua hari dalam seminggu/lebih' => 2],
            'masalah_fokus' => ['Tidak' => 0, 'Ya' => 1, 'Sering' => 2],
            'pola_makan' => ['Tidak sama sekali' => 2, 'Ya' => 1, 'Kadang-kadang' => 0],
            'merasa_bersalah' => ['Tidak' => 0, 'Ya' => 1, 'Mungkin' => 2],
            'suicide_attempt' => ['Tidak' => 0, 'Ya' => 1, 'Tidak ingin menjawab' => 2],
        ];

        return $mapping[$field][$value] ?? null;
    }

    private function convertToText($field, $value)
    {
        $reverseMapping = [
            'umur' => [
                0 => '0-30',
                1 => '31-35',
                2 => '36-40',
                3 => '41-45',
                4 => '46-50'
            ],
            'merasa_sedih' => [0 => 'Tidak', 1 => 'Ya', 2 => 'Kadang-kadang'],
            'mudah_tersinggung' => [0 => 'Tidak', 1 => 'Ya', 2 => 'Kadang-kadang'],
            'masalah_tidur' => [0 => 'Tidak', 1 => 'Ya', 2 => 'Dua hari dalam seminggu/lebih'],
            'masalah_fokus' => [0 => 'Tidak', 1 => 'Ya', 2 => 'Sering'],
            'pola_makan' => [2=> 'Tidak sama sekali', 1 => 'Ya', 0 => 'Kadang-kadang'],
            'merasa_bersalah' => [0 => 'Tidak', 1 => 'Ya', 2 => 'Mungkin'],
            'suicide_attempt' => [0 => 'Tidak', 1 => 'Ya', 2 => 'Tidak ingin menjawab'],
        ];

        return $reverseMapping[$field][$value] ?? "Tidak diketahui";
    }


    private function predictDepresi($data)
    {
        $response = Http::post('https://sehatimldepresi-production.up.railway.app/predict', [
            // $response = Http::post('http://127.0.0.1:5000/predict', [
            'features' => array_values($data)
        ]);

        if ($response->failed()) {
            $status = $response->status();
            $body = $response->body();

            throw new \Exception("Gagal memanggil Flask API. Status: $status. Respons: $body");
        }

        return $response->json()['prediction'] ?? null;
    }

}
