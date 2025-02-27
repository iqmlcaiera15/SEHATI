<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\PrediksiDepresi;
use Illuminate\Support\Facades\Validator;

class PrediksiDepresiController extends Controller
{
    public function index()
    {
        return response()->json(PrediksiDepresi::all());
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'umur' => 'required|integer|min:0|max:120',
            'merasa_sedih' => 'required|in:Tidak,Kadang-kadang,Ya',
            'mudah_tersinggung' => 'required|in:Tidak,Kadang-kadang,Ya',
            'masalah_tidur' => 'required|in:Tidak,Dua hari dalam seminggu/lebih,Ya',
            'masalah_fokus' => 'required|in:Tidak,Ya,Sering',
            'pola_makan' => 'required|in:Tidak sama sekali,Kadang-kadang,Ya',
            'merasa_bersalah' => 'required|in:Tidak,Mungkin,Ya',
            'suicide_attempt' => 'required|in:Tidak,Ya,Tidak ingin menjawab',
        ]);

        if ($validator->fails()) {
            return response()->json([
                "status" => "error",
                "errors" => $validator->errors()
            ], 422);
        }

        $prediksi = PrediksiDepresi::create($request->all());

        return response()->json([
            "status" => "success",
            "message" => "Prediksi berhasil disimpan",
            "data" => $prediksi
        ], 201);
    }

    public function show($id)
    {
        $prediksi = PrediksiDepresi::find($id);

        if (!$prediksi) {
            return response()->json([
                "status" => "error",
                "message" => "Data tidak ditemukan"
            ], 404);
        }

        return response()->json($prediksi);
    }
}
