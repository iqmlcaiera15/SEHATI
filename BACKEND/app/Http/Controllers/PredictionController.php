<?php

namespace App\Http\Controllers;

use App\Models\Prediction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Auth;

class PredictionController extends Controller
{
    public function index(Request $request)
    {
        $query = Prediction::latest();

        // Filter berdasarkan metode persalinan
        if ($request->filled('method')) {
            $query->where('metode_persalinan', $request->method);
        }

        // Filter berdasarkan tanggal prediksi
        if ($request->filled('date')) {
            $query->whereDate('created_at', $request->date);
        }

        // Ambil hasil akhir
        $predictions = $query->get();

        return view('prediksi.index', compact('predictions'));
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'usia_ibu' => 'required|integer|min:15|max:50',
            'tekanan_darah' => 'required|in:normal,rendah,tinggi',
            'riwayat_persalinan' => 'required|in:tidak ada,normal,caesar',
            'posisi_janin' => 'required|in:normal,lintang,sungsang',
            'riwayat_kesehatan_ibu' => 'required|string',
            'kondisi_kesehatan_janin' => 'required|string',
        ]);

        if ($validator->fails()) {
            return redirect()->back()->withErrors($validator)->withInput();
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
                throw new \Exception("Gagal memanggil Flask API. Status: {$response->status()}. Respons: {$response->body()}");
            }

            $result = $response->json();
            $hasil = $result['hasil_prediksi'] ?? null;
            $faktor = $result['faktor'] ?? '-';

            if (!$hasil) {
                throw new \Exception("Respons Flask tidak lengkap: " . json_encode($result));
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
                'user_id' => Auth::id(),
            ]);

            return redirect()->route('bidan.prediksi.result', $prediction->id);

        } catch (\Exception $e) {
            return redirect()->back()->with('error', 'Terjadi kesalahan saat prediksi: ' . $e->getMessage());
        }
    }

    public function deletebyID($id)
    {
        $prediction = Prediction::find($id);

        if (!$prediction) {
            return redirect()->back()->with('error', 'Data tidak ditemukan');
        }

        $prediction->delete();

        return redirect()->route('bidan.prediksi.index')->with('success', 'Riwayat prediksi berhasil dihapus');
    }

    public function result($id)
    {
        $prediction = Prediction::findOrFail($id);

        return view('prediksi.result', compact('prediction'));
    }

    public function print($id)
    {
        $prediction = Prediction::findOrFail($id);

        return view('prediksi.print', compact('prediction'));
    }
}
