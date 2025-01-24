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

    public function deleteAll()
    {
        DeteksiPenyakit::truncate(); 
        return response()->json([
            'status' => 'success',
            'message' => 'All data deleted successfully'
        ], 200);
    }

   
    public function deleteById($id)
    {
        $deteksi = DeteksiPenyakit::find($id);

        if (!$deteksi) {
            return response()->json([
                'status' => 'error',
                'message' => 'Data not found'
            ], 404);
        }

        $deteksi->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Data deleted successfully'
        ], 200);
    }




}





