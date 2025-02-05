<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\SkriningDepresi;
use Illuminate\Support\Facades\Validator;

class SkriningDepresiController extends Controller
{
    // Menampilkan daftar hasil skrining
    public function index()
    {
        $hasilSkrining = SkriningDepresi::all();
        return response()->json($hasilSkrining);
    }

    // Menyimpan hasil skrining Whooley Questionnaire
    public function store(Request $request)
{
    $validator = Validator::make($request->all(), [
        'user_id' => 'required|exists:users,id',
        'whooley_1' => 'required|boolean',
        'whooley_2' => 'required|boolean',
        'sleep_pattern' => 'required|integer|min:0|max:24',
        'eating_pattern' => 'required|integer|min:0|max:10',
        'activity_level' => 'required|integer|min:0|max:10',
        'social_interaction' => 'required|integer|min:0|max:10',
        'stress_level' => 'required|integer|min:0|max:5'
    ]);

    if ($validator->fails()) {
        return response()->json(["error" => $validator->errors()], 422);
    }

    $whooleyResult = $request->whooley_1 || $request->whooley_2;
    $skrining = SkriningDepresi::create([
        'user_id' => $request->user_id,
        'whooley_1' => $request->whooley_1,
        'whooley_2' => $request->whooley_2,
        'whooley_result' => $whooleyResult,
        'epds_score' => null,
        'umur' => $request->umur,
        'jumlah_kelahiran' => $request->jumlah_kelahiran, 
        'jumlah_keguguran' => $request->jumlah_keguguran,
        'status_bekerja' => $request->status_bekerja,
        'tanggal_evaluasi' => $request->tanggal_evaluasi,
        'depression_status' => null, // Akan diperbarui setelah EPDS
    ]);

    return response()->json(["message" => "Skrining awal berhasil disimpan", "data" => $skrining], 201);
}


    // Menyimpan hasil EPDS jika Whooley positif
    public function storeEPDS(Request $request, $id)
{
    $validator = Validator::make($request->all(), [
        'epds_score' => 'required|integer|min:0|max:30'
    ]);

    if ($validator->fails()) {
        return response()->json(["error" => $validator->errors()], 422);
    }

    $skrining = SkriningDepresi::find($id);
    if (!$skrining) {
        return response()->json(["error" => "Data skrining tidak ditemukan"], 404);
    }

    if (!$skrining->whooley_result) {
        return response()->json(["error" => "Pasien tidak memenuhi syarat untuk EPDS"]);
    }

    // Tentukan status depresi (EPDS ≥ 13 dianggap depresi)
    $depressionStatus = $request->epds_score >= 13 ? 1 : 0;

    $skrining->update([
        'epds_score' => $request->epds_score,
        'depression_status' => $depressionStatus
    ]);

    return response()->json(["message" => "EPDS berhasil disimpan", "data" => $skrining]);
}


    // Menampilkan detail hasil skrining berdasarkan ID
    public function show($id)
    {
        $skrining = SkriningDepresi::find($id);
        if (!$skrining) {
            return response()->json(["error" => "Data tidak ditemukan"], 404);
        }
        return response()->json($skrining);
    }
}
