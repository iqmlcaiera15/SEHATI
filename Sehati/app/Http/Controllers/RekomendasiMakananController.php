<?php

namespace App\Http\Controllers;
use App\Models\RekomendasiMakanan;
use Illuminate\Http\Request;

class RekomendasiMakananController extends Controller
{
    public function index()
    {
    $rekomendasi = RekomendasiMakananController::all();

    return response()->json([
        'status' => 'success',
        'data' => $rekomendasi
    ]);
}


    public function show($id)
    {
        $rekomendasi = RekomendasiMakananController::findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data' => $rekomendasi
        ]);
    }
}
