<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\PregnancyCalculator;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class PregnancyCalculatorController extends Controller
{
    // 🔹 Simpan data HPL
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

            $data = PregnancyCalculator::create([
                'user_id' => $user->id,
                'hpht' => $hpht->toDateString(),
                'hpl' => $hpl->toDateString(),
            ]);

            // Hitung usia kehamilan
            $weeks = $hpht->diffInWeeks(now());

            return response()->json([
                'message' => 'Data berhasil disimpan',
                'data' => [
                    'id' => $data->id,
                    'hpht' => $data->hpht,
                    'hpl' => $data->hpl,
                    'minggu_ke' => $weeks
                ]
            ], 201);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'message' => 'Validasi gagal',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Terjadi kesalahan',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // 🔹 Ambil semua data milik user login
    public function index()
    {
        $user = Auth::user();
        $data = PregnancyCalculator::where('user_id', $user->id)->orderBy('created_at', 'desc')->get();

        return response()->json([
            'data' => $data
        ]);
    }

    // 🔹 Tampilkan detail berdasarkan ID
    public function show($id)
    {
        try {
            $data = PregnancyCalculator::findOrFail($id);

            // Optional: validasi agar hanya bisa melihat milik sendiri
            if ($data->user_id !== Auth::id()) {
                return response()->json(['message' => 'Forbidden'], 403);
            }

            return response()->json([
                'data' => $data
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Data tidak ditemukan',
                'error' => $e->getMessage()
            ], 404);
        }
    }

    // 🔹 Hapus data berdasarkan ID
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
            return response()->json([
                'message' => 'Gagal menghapus data',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
