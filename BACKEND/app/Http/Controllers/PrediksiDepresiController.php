<?php

namespace App\Http\Controllers;

use App\Models\Prediction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Auth;

class PredictionController extends Controller
{
    // GET /api/predictions (JSON for mobile) | /bidan/prediksi (Blade for web)
    public function index(Request $request)
    {
        $query = Prediction::latest();

        // Optional filter dari query string
        if ($request->filled('method')) {
            $query->where('metode_persalinan', $request->method);
        }
        if ($request->filled('date')) {
            $query->whereDate('created_at', $request->date);
        }

        // Untuk user mobile: hanya tampilkan miliknya (kecuali role bidan)
        if (Auth::check() && Auth::user()->role == 'user') {
            $query->where('user_id', Auth::id());
        }

        $predictions = $query->get();

        // === MOBILE / FLUTTER (JSON) ===
        if ($request->wantsJson() || $request->is('api/*')) {
            return response()->json([
                'success' => true,
                'data' => $predictions
            ], 200);
        }
        // === WEB (Blade) ===
        return view('prediksi.index', compact('predictions'));
    }

    // POST /api/predictions (JSON for mobile) | /bidan/prediksi (web)
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
            if ($request->wantsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => false,
                    'message' => $validator->errors()->first()
                ], 422);
            }
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
                $msg = "Gagal memanggil Flask API. Status: {$response->status()}. Respons: {$response->body()}";
                if ($request->wantsJson() || $request->is('api/*')) {
                    return response()->json([
                        'success' => false,
                        'message' => $msg
                    ], $response->status());
                }
                throw new \Exception($msg);
            }

            $result = $response->json();
            $hasil = $result['hasil_prediksi'] ?? null;
            $faktor = $result['faktor'] ?? '-';

            if (!$hasil) {
                $msg = "Respons Flask tidak lengkap: " . json_encode($result);
                if ($request->wantsJson() || $request->is('api/*')) {
                    return response()->json([
                        'success' => false,
                        'message' => $msg
                    ], 500);
                }
                throw new \Exception($msg);
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

            if ($request->wantsJson() || $request->is('api/*')) {
                // Kembalikan format sesuai kebutuhan Flutter
                return response()->json([
                    'success' => true,
                    'message' => 'Berhasil melakukan prediksi.',
                    'hasil_prediksi' => $hasil,
                    'faktor' => $faktor,
                    'data' => $prediction
                ], 201);
            }
            // WEB: redirect ke hasil prediksi
            return redirect()->route('bidan.prediksi.result', $prediction->id);
        } catch (\Exception $e) {
            if ($request->wantsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Terjadi kesalahan saat prediksi: ' . $e->getMessage()
                ], 500);
            }
            return redirect()->back()->with('error', 'Terjadi kesalahan saat prediksi: ' . $e->getMessage());
        }
    }

    // DELETE /api/predictions/{id}
    public function deletebyID($id, Request $request)
    {
        $prediction = Prediction::find($id);

        if (!$prediction) {
            if ($request->wantsJson() || $request->is('api/*')) {
                return response()->json(['success' => false, 'message' => 'Data tidak ditemukan'], 404);
            }
            return redirect()->back()->with('error', 'Data tidak ditemukan');
        }

        // Batasi hanya owner/bidan bisa hapus
        if (Auth::id() !== $prediction->user_id && Auth::user()->role !== 'bidan') {
            if ($request->wantsJson() || $request->is('api/*')) {
                return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
            }
            return redirect()->back()->with('error', 'Tidak diizinkan.');
        }

        $prediction->delete();

        if ($request->wantsJson() || $request->is('api/*')) {
            return response()->json(['success' => true, 'message' => 'Riwayat prediksi berhasil dihapus']);
        }
        return redirect()->route('bidan.prediksi.index')->with('success', 'Riwayat prediksi berhasil dihapus');
    }

    // GET /api/predictions/{id}
    public function result($id, Request $request)
    {
        $prediction = Prediction::find($id);

        if (!$prediction) {
            if ($request->wantsJson() || $request->is('api/*')) {
                return response()->json(['success' => false, 'message' => 'Data tidak ditemukan'], 404);
            }
            abort(404);
        }

        // Batasi hanya owner/bidan bisa akses
        if (Auth::id() !== $prediction->user_id && Auth::user()->role !== 'bidan') {
            if ($request->wantsJson() || $request->is('api/*')) {
                return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
            }
            abort(403);
        }

        if ($request->wantsJson() || $request->is('api/*')) {
            return response()->json([
                'success' => true,
                'data' => $prediction
            ]);
        }
        return view('prediksi.result', compact('prediction'));
    }

    // Untuk web print view
    public function print($id)
    {
        $prediction = Prediction::findOrFail($id);
        return view('prediksi.print', compact('prediction'));
    }
}
