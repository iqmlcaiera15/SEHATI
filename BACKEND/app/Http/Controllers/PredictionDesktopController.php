<?php

namespace App\Http\Controllers;

use App\Models\Prediction;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Auth;

class PredictionDesktopController extends Controller
{
    // Tampilkan seluruh prediksi (bidan/admin: bisa lihat semua user)
    public function index(Request $request)
    {
        $user = Auth::user();
        if (!$user) {
            return redirect()->route('login')->with('error', 'Harap login terlebih dahulu.');
        }

        $query = Prediction::latest();

        // Filter opsional
        if ($request->filled('method')) {
            $query->where('metode_persalinan', $request->method);
        }
        if ($request->filled('date')) {
            $query->whereDate('created_at', $request->date);
        }
        if ($request->filled('user_id')) {
            $query->where('user_id', $request->user_id);
        }

        $predictions = $query->get();
        $users = User::all(); // Untuk filter & pilihan user di form

        return view('prediksi.index', compact('predictions', 'users'));
    }

    // Form tambah prediksi
    public function create()
    {
        $user = Auth::user();
        if (!$user) {
            return redirect()->route('login')->with('error', 'Harap login terlebih dahulu.');
        }
        $users = User::all();
        return view('prediksi.form', compact('users'));
    }

    // Proses simpan prediksi
    public function store(Request $request)
    {
        $user = Auth::user();
        if (!$user) {
            return redirect()->route('login')->with('error', 'Harap login terlebih dahulu.');
        }

        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id', // bidan bisa pilih user
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
                return redirect()->back()->with('error', 'Gagal memanggil Flask API: ' . $response->body());
            }

            $result = $response->json();
            $hasil = $result['hasil_prediksi'] ?? null;
            $faktor = $result['faktor'] ?? '-';

            if (!$hasil) {
                return redirect()->back()->with('error', 'Respons Flask tidak lengkap: ' . json_encode($result));
            }

            $prediction = Prediction::create([
                'user_id' => $request->user_id, // bisa dipilih dari form
                'usia_ibu' => $dataToSend['usia_ibu'],
                'tekanan_darah' => $dataToSend['tekanan_darah'],
                'riwayat_persalinan' => $dataToSend['riwayat_persalinan'],
                'posisi_janin' => $dataToSend['posisi_janin'],
                'riwayat_kesehatan_ibu' => $dataToSend['riwayat_kesehatan_ibu'],
                'kondisi_kesehatan_janin' => $dataToSend['kondisi_kesehatan_janin'],
                'metode_persalinan' => $hasil,
                'faktor' => $faktor,
            ]);

            return redirect()->route('prediksi.show', $prediction->id)
                ->with('success', 'Data prediksi berhasil disimpan!');
        } catch (\Exception $e) {
            return redirect()->back()->with('error', 'Terjadi kesalahan saat prediksi: ' . $e->getMessage());
        }
    }

    // Detail prediksi (show)
    public function show($id)
    {
        $user = Auth::user();
        if (!$user) {
            return redirect()->route('login')->with('error', 'Harap login terlebih dahulu.');
        }

        $prediction = Prediction::findOrFail($id);

        return view('prediksi.result', compact('prediction'));
    }

    // Print
    public function print($id)
    {
        $user = Auth::user();
        if (!$user) {
            return redirect()->route('login')->with('error', 'Harap login terlebih dahulu.');
        }

        $prediction = Prediction::findOrFail($id);
        return view('prediksi.print', compact('prediction'));
    }

    // Hapus 1 prediksi
    public function destroy($id)
    {
        $user = Auth::user();
        if (!$user) {
            return redirect()->route('login')->with('error', 'Harap login terlebih dahulu.');
        }

        $prediction = Prediction::findOrFail($id);
        $prediction->delete();

        return redirect()->route('prediksi.index')->with('success', 'Data prediksi berhasil dihapus');
    }

    // Hapus semua prediksi milik user tertentu (opsional)
    public function deleteAll(Request $request)
    {
        $user = Auth::user();
        if (!$user) {
            return redirect()->route('login')->with('error', 'Harap login terlebih dahulu.');
        }

        if ($request->filled('user_id')) {
            Prediction::where('user_id', $request->user_id)->delete();
        } else {
            Prediction::truncate();
        }

        return redirect()->route('prediksi.index')->with('success', 'Semua data prediksi berhasil dihapus');
    }

    // Tampilkan data prediksi terbaru
    public function latest()
    {
        $prediction = Prediction::latest()->first();

        if (!$prediction) {
            return redirect()->route('prediksi.index')->with('info', 'Belum ada data prediksi');
        }

        return redirect()->route('prediksi.show', ['id' => $prediction->id]);
    }
}
