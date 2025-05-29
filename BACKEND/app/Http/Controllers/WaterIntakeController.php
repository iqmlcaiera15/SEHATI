<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\WaterIntake;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class WaterIntakeController extends Controller
{
    /**
     * 🔹 Simpan konsumsi air 250ml per klik (maks 2000ml per hari per user)
     */
    public function store(Request $request)
    {
        try {
            $user = $request->user();

            if (!$user) {
                return response()->json(['message' => 'Unauthorized'], 401);
            }

            $todayDate = Carbon::today('Asia/Jakarta')->toDateString();

            $totalToday = WaterIntake::where('user_id', $user->id)
                ->where('tanggal', $todayDate)
                ->sum('jumlah_ml');

            if ($totalToday >= 2000) {
                return response()->json([
                    'message' => 'Batas konsumsi air hari ini telah tercapai',
                    'total_ml_today' => $totalToday,
                    'max_reached' => true
                ], 400);
            }

            $entry = WaterIntake::create([
                'user_id' => $user->id,
                'jumlah_ml' => 250,
                'tanggal' => $todayDate,
            ]);

            return response()->json([
                'message' => 'Konsumsi air berhasil disimpan',
                'data' => $entry,
                'total_ml_today' => $totalToday + 250,
                'max_reached' => false
            ], 201);
        } catch (\Exception $e) {
            Log::error('❌ Gagal menyimpan data air', ['error' => $e->getMessage()]);
            return response()->json([
                'message' => 'Terjadi kesalahan saat menyimpan data',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * 🔹 Tampilkan riwayat konsumsi air 7 hari terakhir (termasuk hari ini)
     */
    public function index()
    {
        try {
            $user = Auth::user();

            if (!$user) {
                return response()->json(['message' => 'Unauthorized'], 401);
            }

            $today = Carbon::today('Asia/Jakarta');
            $history = collect();

            for ($i = 6; $i >= 0; $i--) {
                $date = $today->copy()->subDays($i)->toDateString();
                $jumlah = WaterIntake::where('user_id', $user->id)
                    ->where('tanggal', $date)
                    ->sum('jumlah_ml');

                $history->push([
                    'tanggal' => $date,
                    'jumlah_ml' => $jumlah,
                ]);
            }

            $totalKonsumsiHariIni = WaterIntake::where('user_id', $user->id)
                ->where('tanggal', $today->toDateString())
                ->sum('jumlah_ml');

            return response()->json([
                'message' => 'Data riwayat berhasil diambil',
                'total_konsumsi' => $totalKonsumsiHariIni,
                'history' => $history,
            ]);
        } catch (\Exception $e) {
            Log::error('❌ Gagal mengambil riwayat air', ['error' => $e->getMessage()]);
            return response()->json([
                'message' => 'Terjadi kesalahan saat mengambil data',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
