<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\DeteksiPenyakit;

class DeteksiController extends Controller
{
    public function index()
    {
        $DeteksiPenyakit = DeteksiPenyakit::all();

        return response()->json([
            'DeteksiPenyakit' => $DeteksiPenyakit
        ]);
    }
    
    public function store(Request $request)
    {
        $request->validate([
            'nama' => 'required',
            'umur' => 'required',
            'bmi' => 'required',
            'tekanan_darah' => 'required',
            'hemoglobin' => 'required',
        ]);

        DeteksiPenyakit::create([
            'nama' => $request->nama,
            'umur' => $request->umur,
            'bmi' => $request->bmi,
            'tekanan_darah' => $request->tekanan_darah,
            'hemoglobin' => $request->hemoglobin,

        ]);
        return response()->json([
            'status' => 'success',
            'message' => 'Status created successfully'
        ], 201);
    }
      
}