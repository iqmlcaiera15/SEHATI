<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\WaterIntake;

class WaterIntakeController extends Controller
{
    // Menampilkan total konsumsi air dan riwayat
    public function index()
    {
        $totalKonsumsi = WaterIntake::sum('jumlah_ml');
        $history = WaterIntake::orderBy('created_at', 'desc')->get();

        return response()->json([
            'total_konsumsi' => $totalKonsumsi,
            'history' => $history
        ]);
    }

    // Menyimpan data konsumsi air (default 250ml per klik)
    public function store()
    {
        $waterIntake = WaterIntake::create([
            'jumlah_ml' => 250
        ]);

        return response()->json([
            'message' => 'Data berhasil disimpan',
            'data' => $waterIntake
        ]);
    }

    // Menampilkan detail konsumsi air tertentu
    public function show($id)
    {
        $waterIntake = WaterIntake::findOrFail($id);
        return response()->json($waterIntake);
    }

    // Mengupdate konsumsi air
    public function update(Request $request, $id)
    {
        $request->validate([
            'jumlah_ml' => 'required|integer|min:1',
        ]);

        $waterIntake = WaterIntake::findOrFail($id);
        $waterIntake->update([
            'jumlah_ml' => $request->jumlah_ml,
        ]);

        return response()->json(['message' => 'Data berhasil diperbarui']);
    }

    // Menghapus konsumsi air
    public function destroy($id)
    {
        WaterIntake::findOrFail($id)->delete();
        return response()->json(['message' => 'Data berhasil dihapus']);
    }
}
