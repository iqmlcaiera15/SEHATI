<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\PrediksiDepresi;

class PrediksiDepresiDesktopController extends Controller
{
    public function index()
    {
        $prediksiList = PrediksiDepresi::with(['user', 'epds'])->paginate(10);
        return view('depresi.index', compact('prediksiList'));

        if ($request->filled('hasil')) {
        $query->where('hasil_prediksi', $request->hasil);
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
