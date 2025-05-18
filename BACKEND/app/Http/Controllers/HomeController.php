<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\DeteksiPenyakit;
use App\Models\PrediksiDepresi;
use App\Models\Prediction;


class HomeController extends Controller
{
    // public function __construct()
    // {
    //     $this->middleware('check.role:bidan');
    // }

    public function index()
    {
        $ibuHamil = User::where('role', 'ibu_hamil')->get();
        // $ibuHamil = User::all();
      
        // Data lainnya tanpa optimasi
        $deteksiPenyakit = DeteksiPenyakit::all();
        $prediksiDepresi = PrediksiDepresi::all();
        $prediksiJanin = Prediction::all();

        return view('bidan.dashboard', [
            'ibuHamil' => $ibuHamil,
            'deteksiPenyakit' => $deteksiPenyakit,
            'prediksiDepresi' => $prediksiDepresi,
            'prediksiJanin' => $prediksiJanin
        ]);
    }

       public function index_dinkes()
    {
        $ibuHamil = User::where('role', 'ibu_hamil')->get();
        // $ibuHamil = User::all();
      
        // Data lainnya tanpa optimasi
        $deteksiPenyakit = DeteksiPenyakit::all();
        $prediksiDepresi = PrediksiDepresi::all();
        $prediksiJanin = Prediction::all();

        return view('dinkes.dashboardd', [
            'ibuHamil' => $ibuHamil,
            'deteksiPenyakit' => $deteksiPenyakit,
            'prediksiDepresi' => $prediksiDepresi,
            'prediksiJanin' => $prediksiJanin
        ]);
    }
}
