<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\DeteksiPenyakit;
use App\Models\PrediksiDepresi;
use App\Models\Prediction;
use Illuminate\Http\Request;

class BidanHomeController extends Controller
{
    public function index()
    {
        // Data ibu hamil (tetap difilter)
        $ibuHamil = User::where('role', 'ibu_hamil')->get();

        // Data lainnya tanpa optimasi
        $deteksiPenyakit = DeteksiPenyakit::all();
        $prediksiDepresi = PrediksiDepresi::all();
        $prediksiJanin = Prediction::all();

        return view('bidan-dinkes.home', [
            'ibuHamil' => $ibuHamil,
            'deteksiPenyakit' => $deteksiPenyakit,
            'prediksiDepresi' => $prediksiDepresi,
            'prediksiJanin' => $prediksiJanin
        ]);
    }
}