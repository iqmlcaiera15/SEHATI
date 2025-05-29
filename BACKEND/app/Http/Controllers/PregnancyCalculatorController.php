<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\PregnancyCalculator;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class PregnancyCalculatorController extends Controller
{
    /**
     * 🔹 Simpan data HPL berdasarkan HPHT user
     */
    public function store(Request $request)
    {
        try {
            $request->validate([
                'hpht' => 'required|date',
            ]);

            $user = $request->user();

            if (!$user) {
                return response()->json(['message' => 'Unauthorized'], 401);
            }

            $hpht = Carbon::parse($request->hpht);
            $hpl = $hpht->copy()->addDays(7)->subMonthsNoOverflow(3)->addYear();
            $mingguKe = $hpht->diffInWeeks(now('Asia/Jakarta'));

            $data = PregnancyCalculator::create([
                'user_id' => $user->id,
                'hpht' => $hpht->toDateString(),
                'hpl' => $hpl->toDateString(),
            ]);

            return response()->json([
                'message' => 'Data kehamilan berhasil disimpan',
                'data' => [
                    'id' => $data->id,
                    'hpht' => $data->hpht,
                    'hpl' => $data->hpl,
                    'minggu_ke' => $mingguKe
                ]
            ], 201);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'message' => 'Validasi gagal',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            Log::error('❌ Gagal menyimpan HPL:', ['error' => $e->getMessage()]);
            return response()->json([
                'message' => 'Terjadi kesalahan saat menyimpan data',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * 🔹 Ambil semua data kehamilan semua user (untuk bidan)
     */
    public function index()
    {
        try {
            $data = PregnancyCalculator::with('user')->orderBy('created_at', 'desc')->get();

            return response()->json([
                'message' => 'Data berhasil diambil',
                'data' => $data
            ]);
        } catch (\Exception $e) {
            Log::error('❌ Gagal mengambil data kehamilan:', ['error' => $e->getMessage()]);
            return response()->json([
                'message' => 'Gagal mengambil data',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * 🔹 Tampilkan detail berdasarkan ID
     */
    public function show($id)
    {
        try {
            $data = PregnancyCalculator::with('user')->findOrFail($id);

            return response()->json([
                'message' => 'Detail data berhasil diambil',
                'data' => $data
            ]);
        } catch (\Exception $e) {
            Log::error('❌ Gagal menampilkan detail HPL:', ['error' => $e->getMessage()]);
            return response()->json([
                'message' => 'Data tidak ditemukan',
                'error' => $e->getMessage()
            ], 404);
        }
    }

    /**
     * 🔹 Hapus data berdasarkan ID (hanya oleh pemilik)
     */
    public function destroy($id)
    {
        try {
            $data = PregnancyCalculator::findOrFail($id);

            if ($data->user_id !== Auth::id()) {
                return response()->json(['message' => 'Forbidden'], 403);
            }

            $data->delete();

            return response()->json([
                'message' => 'Data berhasil dihapus'
            ]);
        } catch (\Exception $e) {
            Log::error('❌ Gagal menghapus data kehamilan:', ['error' => $e->getMessage()]);
            return response()->json([
                'message' => 'Gagal menghapus data',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
