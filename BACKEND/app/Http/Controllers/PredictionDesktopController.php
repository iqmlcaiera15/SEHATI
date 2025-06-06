<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Auth;
use App\Models\Prediction;
use App\Models\User;

class PredictionDesktopController extends Controller
{
    public function index(Request $request)
    {
        $user = Auth::user();

        // Jika bidan, lihat semua. Jika bukan, hanya data miliknya
        if ($user->role === 'bidan') {
            $query = Prediction::with(['user', 'hpl'])->latest();

            if ($request->filled('method')) {
                $query->where('metode_persalinan', $request->method);
            }
            if ($request->filled('user_id')) {
                $query->where('user_id', $request->user_id);
            }
            // FILTER HPL
            if ($request->filled('hpl')) {
                $query->whereHas('hpl', function ($q) use ($request) {
                    $q->whereDate('hpl', $request->hpl);
                });
            }

            $predictions = $query->get();
        } else {
            $predictions = Prediction::with(['user', 'hpl'])
                ->where('user_id', $user->id)
                ->when($request->filled('hpl'), function ($q) use ($request) {
                    $q->whereHas('hpl', function ($sub) use ($request) {
                        $sub->whereDate('hpl', $request->hpl);
                    });
                })
                ->latest()
                ->get();
        }

        $users = User::all();
        return view('prediksi.index', compact('predictions', 'users'));
    }

    public function show($id)
    {
        $user = Auth::user();
        $prediction = Prediction::with(['user', 'hpl'])->findOrFail($id);

        // Jika bukan bidan, hanya bisa lihat milik sendiri
        if ($user->role !== 'bidan' && $user->id !== $prediction->user_id) {
            return redirect()->route('prediksi.index')->with('error', 'Anda tidak memiliki akses ke data ini');
        }

        return view('prediksi.result', compact('prediction'));
    }

    public function print($id)
    {
        $user = Auth::user();
        $prediction = Prediction::with(['user', 'hpl'])->findOrFail($id);

        // Jika bukan bidan, hanya bisa lihat milik sendiri
        if ($user->role !== 'bidan' && $user->id !== $prediction->user_id) {
            return redirect()->route('prediksi.index')->with('error', 'Anda tidak memiliki akses ke data ini');
        }

        return view('prediksi.print', compact('prediction'));
    }

    public function indexlatest()
    {
        $user = Auth::user();

        $prediction = $user->role === 'bidan'
            ? Prediction::with(['user', 'hpl'])->latest()->first()
            : Prediction::with(['user', 'hpl'])->where('user_id', $user->id)->latest()->first();

        if (!$prediction) {
            return redirect()->route('prediksi.index')->with('info', 'Belum ada data prediksi');
        }

        return redirect()->route('prediksi.show', ['id' => $prediction->id]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'usia_ibu' => 'required|integer|min:15|max:50',
            'tekanan_darah' => 'required|in:normal,rendah,tinggi',
            'riwayat_persalinan' => 'required|in:tidak ada,normal,caesar',
            'posisi_janin' => 'required|in:normal,lintang,sungsang',
            'riwayat_kesehatan_ibu' => 'required|string',
            'kondisi_kesehatan_janin' => 'required|string',
        ]);

        try {
            $dataToSend = [
                'usia_ibu' => (int)$request->usia_ibu,
                'tekanan_darah' => strtolower($request->tekanan_darah),
                'riwayat_persalinan' => strtolower($request->riwayat_persalinan),
                'posisi_janin' => strtolower($request->posisi_janin),
                'riwayat_kesehatan_ibu' => strtolower($request->riwayat_kesehatan_ibu),
                'kondisi_kesehatan_janin' => strtolower($request->kondisi_kesehatan_janin),
            ];

            // Request ke Flask
            $response = Http::post('https://sehatimlprediksi-production.up.railway.app/predict', $dataToSend);
            $result = $response->json();

            if (!$response->ok() || !isset($result['hasil_prediksi'])) {
                return redirect()->back()->with('error', 'Prediksi gagal. Coba lagi.');
            }

            $prediction = Prediction::create([
                'user_id' => $request->user_id,
                'usia_ibu' => $dataToSend['usia_ibu'],
                'tekanan_darah' => $dataToSend['tekanan_darah'],
                'riwayat_persalinan' => $dataToSend['riwayat_persalinan'],
                'posisi_janin' => $dataToSend['posisi_janin'],
                'riwayat_kesehatan_ibu' => $dataToSend['riwayat_kesehatan_ibu'],
                'kondisi_kesehatan_janin' => $dataToSend['kondisi_kesehatan_janin'],
                'metode_persalinan' => $result['hasil_prediksi'],
                'faktor' => $result['faktor'] ?? '-',
            ]);

            return redirect()->route('prediksi.show', $prediction->id)
                ->with('success', 'Data prediksi berhasil disimpan!');
        } catch (\Exception $e) {
            return redirect()->back()->with('error', 'Terjadi kesalahan saat prediksi: ' . $e->getMessage());
        }
    }

    public function deleteAll()
    {
        $user = Auth::user();

        if ($user->role === 'bidan') {
            Prediction::truncate();
        } else {
            Prediction::where('user_id', $user->id)->delete();
        }

        return redirect()->route('prediksi.index')->with('success', 'Semua data prediksi berhasil dihapus');
    }

    public function destroy($id)
    {
        $user = Auth::user();
        $prediction = Prediction::findOrFail($id);

        // Jika bukan bidan, hanya bisa hapus milik sendiri
        if ($user->role !== 'bidan' && $user->id !== $prediction->user_id) {
            return redirect()->route('prediksi.index')->with('error', 'Anda tidak memiliki akses menghapus data ini');
        }

        $prediction->delete();
        return redirect()->route('prediksi.index')->with('success', 'Data prediksi berhasil dihapus');
    }
}
