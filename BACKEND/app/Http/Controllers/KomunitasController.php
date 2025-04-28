<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Komunitas;

class KomunitasController extends Controller
{
    public function index()
    {
        $Komunitas = Komunitas::all();

        return response()->json([
            'Komunitas' => $Komunitas
        ]);
    }
    
    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required',
            'judul' => 'required',
            'deskripsi' => 'required',

        ]);

        Komunitas::create([
            'user_id' => $request->user_id,
            'judul' => $request->judul,
            'deskripsi' => $request->deskripsi,
            'komen' => $request->komen,
            'likes' => $request->likes,
        X
        ]);
        return response()->json([
            'status' => 'berhasil',
            'message' => 'Status created successfully'
        ], 201);
    }

    public function deleteAll()
    {
        CatatanKunjungan::truncate(); 
        return response()->json([
            'status' => 'success',
            'message' => 'All data deleted successfully'
        ], 200);
    }

   
    public function deleteById($id)
    {
        $deteksi = CatatanKunjungan::find($id);

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
