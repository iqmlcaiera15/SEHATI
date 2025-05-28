<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\WaterIntake;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class WaterIntakeController extends Controller
{
    // 🔹 Simpan konsumsi air 250ml per klik (maks 2000ml per hari)
    public function store(Request $request)
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json(['message' => 'Unauthorized'], 401);
            }

            $today = Carbon::today('Asia/Jakarta');
            $totalToday = WaterIntake::where('user_id', $user->id)
                ->whereDate('created_at', $today)
                ->sum('jumlah_ml');

            if ($totalToday >= 2000) {
                return response()->json([
                    'message' => 'Batas konsumsi hari ini telah tercapai',
                    'max_reached' => true
                ], 400);
            }

            $waterIntake = WaterIntake::create([
                'user_id' => $user->id,
                'jumlah_ml' => 250,
                'created_at' => now(),
            ]);

            return response()->json([
                'message' => 'Data berhasil disimpan',
                'data' => $waterIntake,
                'total_ml_today' => $totalToday + 250,
                'max_reached' => false
            ], 201);
        } catch (\Exception $e) {
            Log::error('❌ Gagal menyimpan data air:', ['error' => $e->getMessage()]);
            return response()->json([
                'message' => 'Terjadi kesalahan saat menyimpan data',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // 🔹 Tampilkan riwayat konsumsi 7 hari terakhir
    public function index()
    {
        try {
            $user = Auth::user();
            if (!$user) {
                return response()->json(['message' => 'Unauthorized'], 401);
            }

            $today = Carbon::now('Asia/Jakarta')->startOfDay();
            $history = collect();

            for ($i = 6; $i >= 0; $i--) {
                $date = $today->copy()->subDays($i);
                $jumlah = WaterIntake::where('user_id', $user->id)
                    ->whereDate('created_at', $date)
                    ->sum('jumlah_ml');

                $history->push([
                    'tanggal' => $date->toDateString(),
                    'jumlah_ml' => $jumlah,
                ]);
            }

            $totalKonsumsi = WaterIntake::where('user_id', $user->id)
                ->whereDate('created_at', $today)
                ->sum('jumlah_ml');

            return response()->json([
                'total_konsumsi' => $totalKonsumsi,
                'history' => $history,
            ]);
        } catch (\Exception $e) {
            Log::error('❌ Gagal mengambil data riwayat air:', ['error' => $e->getMessage()]);
            return response()->json([
                'message' => 'Terjadi kesalahan saat mengambil data',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
