<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\PrediksiDepresi;

class DepresiDesktopController extends Controller
{
    public function index(Request $request)
    {
        $query = PrediksiDepresi::with(['user', 'epds'])
                                ->orderBy('created_at', 'desc');

        // Filter berdasarkan tanggal
        if ($request->filled('tanggal')) {
            $tanggal = $request->tanggal;
            $query->whereDate('created_at', $tanggal);
        }

        // Filter berdasarkan hasil
        if ($request->filled('hasil')) {
            if ($request->hasil == 'bergejala') {
                // Filter untuk yang bergejala depresi
                $query->where(function($q) {
                    // Kondisi 1: hasil_prediksi = 1
                    $q->where('hasil_prediksi', 1)
                      // Kondisi 2: hasil_prediksi = 0 tapi skor EPDS >= 12
                      ->orWhere(function($subQuery) {
                          $subQuery->where('hasil_prediksi', 0)
                                   ->whereHas('epds', function($epdsQuery) {
                                       $epdsQuery->where('score', '>=', 12);
                                   });
                      });
                });
            } elseif ($request->hasil == 'tidak_bergejala') {
                // Filter untuk yang tidak bergejala depresi
                $query->where(function($q) {
                    // hasil_prediksi = 0 dan (tidak ada EPDS atau skor EPDS < 12)
                    $q->where('hasil_prediksi', 0)
                      ->where(function($subQuery) {
                          $subQuery->whereDoesntHave('epds')
                                   ->orWhereHas('epds', function($epdsQuery) {
                                       $epdsQuery->where('score', '<', 12);
                                   });
                      });
                });
            }
        }

        $prediksiList = $query->paginate(10);

        return view('depresi.index', compact('prediksiList'));
    }

    public function show($id)
    {
        $prediksi = PrediksiDepresi::with(['user', 'epds'])->findOrFail($id);
        return view('depresi.show', compact('prediksi'));
    }

    public function destroy($id)
    {
        $prediksi = PrediksiDepresi::find($id);
        
        if (!$prediksi) {
            return redirect()->route('depresi.index')
                             ->with('error', 'Data tidak ditemukan');
        }

        $prediksi->delete();

        return redirect()->route('depresi.index')
                         ->with('success', 'History prediksi berhasil dihapus');
    }
}