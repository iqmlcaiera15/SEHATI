<?php

namespace App\Http\Controllers;
use Illuminate\Http\Request;
use App\Models\PrediksiDepresi;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Http;

class PrediksiDepresiDekstopController extends Controller
{       
    public function index()
    {
        // Get all prediction data
        $prediksi = PrediksiDepresi::all();
        
        // Return view with data
        return view('depresi.index', compact('prediksi'));
    }

    public function deletebyID($id)
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