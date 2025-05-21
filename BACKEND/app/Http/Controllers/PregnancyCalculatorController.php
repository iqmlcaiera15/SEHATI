<?php

namespace App\Http\Controllers;

use App\Models\PregnancyCalculator;
use Illuminate\Http\Request;
use Carbon\Carbon;

class PregnancyCalculatorController extends Controller
{
    // Menampilkan semua data
    public function index()
    {
        $data = PregnancyCalculator::orderBy('created_at', 'desc')->get();
        return response()->json($data);
    }

    // Menyimpan data baru
    public function store(Request $request)
    {
        $request->validate([
            'hpht' => 'required|date',
        ]);

        // Hitung HPL = HPHT + 280 hari
        $hpl = Carbon::parse($request->hpht)->addDays(280);

        $data = PregnancyCalculator::create([
            'hpht' => $request->hpht,
            'hpl' => $hpl,
        ]);

        return response()->json([
            'message' => 'Data berhasil disimpan',
            'data' => $data
        ]);
    }

    // Menampilkan satu data
    public function show($id)
    {
        $data = PregnancyCalculator::findOrFail($id);
        return response()->json($data);
    }

    // Mengupdate data
    public function update(Request $request, $id)
    {
        $request->validate([
            'hpht' => 'required|date',
        ]);

        $data = PregnancyCalculator::findOrFail($id);
        $hpl = Carbon::parse($request->hpht)->addDays(280);

        $data->update([
            'hpht' => $request->hpht,
            'hpl' => $hpl,
        ]);

        return response()->json(['message' => 'Data berhasil diperbarui']);
    }

    // Menghapus data
    public function destroy($id)
    {
        PregnancyCalculator::findOrFail($id)->delete();
        return response()->json(['message' => 'Data berhasil dihapus']);
    }
}
