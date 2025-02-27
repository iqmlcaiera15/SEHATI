<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\PrediksiDepresi;
use Illuminate\Support\Facades\Validator;

class PrediksiDepresiController extends Controller
{
    public function index()
    {
        return response()->json(PrediksiDepresi::all());
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'umur' => 'required|integer|min:0|max:120',
            'merasa_sedih' => 'required|in:Tidak,Kadang-kadang,Ya',
            'mudah_tersinggung' => 'required|in:Tidak,Kadang-kadang,Ya',
            'masalah_tidur' => 'required|in:Tidak,Dua hari dalam seminggu/lebih,Ya',
            'masalah_fokus' => 'required|in:Tidak,Ya,Sering',
            'pola_makan' => 'required|in:Tidak sama sekali,Kadang-kadang,Ya',
            'merasa_bersalah' => 'required|in:Tidak,Mungkin,Ya',
            'suicide_attempt' => 'required|in:Tidak,Ya,Tidak ingin menjawab',
        ]);

        if ($validator->fails()) {
            return response()->json([
                "status" => "error",
                "errors" => $validator->errors()
            ], 422);
        }

        // Konversi jawaban ke angka ((sebelum masuk ke SVM))
        $dataKuisioner = [
            'umur' => $request->umur,
            'merasa_sedih' => $this->convertToNumber('merasa_sedih', $request->merasa_sedih),
            'mudah_tersinggung' => $this->convertToNumber('mudah_tersinggung', $request->mudah_tersinggung),
            'masalah_tidur' => $this->convertToNumber('masalah_tidur', $request->masalah_tidur),
            'masalah_fokus' => $this->convertToNumber('masalah_fokus', $request->masalah_fokus),
            'pola_makan' => $this->convertToNumber('pola_makan', $request->pola_makan),
            'merasa_bersalah' => $this->convertToNumber('merasa_bersalah', $request->merasa_bersalah),
            'suicide_attempt' => $this->convertToNumber('suicide_attempt', $request->suicide_attempt),
        ];

        // Kirim data ke model SVM (simulasi hasil prediksi dari model SVM)
        $dataKuisioner['hasil_prediksi'] = $this->predictDepresi($dataKuisioner);

        // Simpan ke database
        $prediksi = PrediksiDepresi::create($dataKuisioner);

        return response()->json([
            "status" => "success",
            "message" => "Prediksi berhasil disimpan",
            "data" => $prediksi
        ], 201);
    }

    public function show($id)
    {
        $prediksi = PrediksiDepresi::find($id);

        if (!$prediksi) {
            return response()->json([
                "status" => "error",
                "message" => "Data tidak ditemukan"
            ], 404);
        }

        // Konversi angka kembali ke teks
        $rekapData = [
            'umur' => $prediksi->umur,
            'merasa_sedih' => $this->convertToText('merasa_sedih', $prediksi->merasa_sedih),
            'mudah_tersinggung' => $this->convertToText('mudah_tersinggung', $prediksi->mudah_tersinggung),
            'masalah_tidur' => $this->convertToText('masalah_tidur', $prediksi->masalah_tidur),
            'masalah_fokus' => $this->convertToText('masalah_fokus', $prediksi->masalah_fokus),
            'pola_makan' => $this->convertToText('pola_makan', $prediksi->pola_makan),
            'merasa_bersalah' => $this->convertToText('merasa_bersalah', $prediksi->merasa_bersalah),
            'suicide_attempt' => $this->convertToText('suicide_attempt', $prediksi->suicide_attempt),
            'hasil_prediksi' => $prediksi->hasil_prediksi ? "Terindikasi Depresi" : "Tidak Terindikasi Depresi"
        ];

        return response()->json([
            "status" => "success",
            "data" => $rekapData
        ]);
    }

    // Fungsi Konversi Kuisioner ke Angka
    private function convertToNumber($field, $value)
    {
        $mapping = [
            'merasa_sedih' => ['Tidak' => 0, 'Kadang-kadang' => 1, 'Ya' => 2],
            'mudah_tersinggung' => ['Tidak' => 0, 'Kadang-kadang' => 1, 'Ya' => 2],
            'masalah_tidur' => ['Tidak' => 0, 'Dua hari dalam seminggu/lebih' => 1, 'Ya' => 2],
            'masalah_fokus' => ['Tidak' => 0, 'Ya' => 1, 'Sering' => 2],
            'pola_makan' => ['Tidak sama sekali' => 0, 'Kadang-kadang' => 1, 'Ya' => 2],
            'merasa_bersalah' => ['Tidak' => 0, 'Mungkin' => 1, 'Ya' => 2],
            'suicide_attempt' => ['Tidak' => 0, 'Ya' => 1, 'Tidak ingin menjawab' => 2],
        ];

        return $mapping[$field][$value] ?? null;
    }

    // Fungsi Konversi Angka ke Teks
    private function convertToText($field, $value)
    {
        $reverseMapping = [
            'merasa_sedih' => [0 => 'Tidak', 1 => 'Kadang-kadang', 2 => 'Ya'],
            'mudah_tersinggung' => [0 => 'Tidak', 1 => 'Kadang-kadang', 2 => 'Ya'],
            'masalah_tidur' => [0 => 'Tidak', 1 => 'Dua hari dalam seminggu/lebih', 2 => 'Ya'],
            'masalah_fokus' => [0 => 'Tidak', 1 => 'Ya', 2 => 'Sering'],
            'pola_makan' => [0 => 'Tidak sama sekali', 1 => 'Kadang-kadang', 2 => 'Ya'],
            'merasa_bersalah' => [0 => 'Tidak', 1 => 'Mungkin', 2 => 'Ya'],
            'suicide_attempt' => [0 => 'Tidak', 1 => 'Ya', 2 => 'Tidak ingin menjawab'],
        ];

        return $reverseMapping[$field][$value] ?? "Tidak diketahui";
    }

    // Fungsi Prediksi SVM (Simulasi)
    private function predictDepresi($data)
    {
        // Panggil model SVM untuk prediksi (sementara return random)
        return rand(0, 1); // 0: Tidak Terindikasi, 1: Terindikasi
    }
}