<?php

namespace App\Http\Controllers;

use App\Models\PregnancyCalculator;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class PregnancyCalculatorController extends Controller
{
    // 🔹 Tampilkan semua data HPL milik user
    public function index()
    {
        $user = Auth::user();
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        $data = PregnancyCalculator::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'data' => $data
        ]);
    }

    // 🔹 Hitung & Simpan data HPL
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
            $mingguKe = now()->diffInWeeks($hpht);

            $data = PregnancyCalculator::create([
                'user_id' => $user->id,
                'hpht' => $hpht->toDateString(),
                'hpl' => $hpl->toDateString(),
            ]);

            return response()->json([
                'message' => 'Data berhasil disimpan',
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
                'message' => 'Gagal menyimpan data',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // 🔹 Tampilkan 1 data berdasarkan ID milik user
    public function show($id)
    {
        $user = Auth::user();
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        $data = PregnancyCalculator::where('user_id', $user->id)->findOrFail($id);

        return response()->json(['data' => $data]);
    }

    // 🔹 Update data berdasarkan ID
    public function update(Request $request, $id)
    {
        try {
            $request->validate([
                'hpht' => 'required|date',
            ]);

            $user = $request->user();
            if (!$user) {
                return response()->json(['message' => 'Unauthorized'], 401);
            }

            $data = PregnancyCalculator::where('user_id', $user->id)->findOrFail($id);

            $hpht = Carbon::parse($request->hpht);
            $hpl = $hpht->copy()->addDays(7)->subMonthsNoOverflow(3)->addYear();

            $data->update([
                'hpht' => $hpht->toDateString(),
                'hpl' => $hpl->toDateString(),
            ]);

            return response()->json([
                'message' => 'Data berhasil diperbarui',
                'data' => $data
            ]);
        } catch (\Exception $e) {
            Log::error('❌ Gagal update HPL:', ['error' => $e->getMessage()]);
            return response()->json([
                'message' => 'Gagal memperbarui data',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // 🔹 Hapus data berdasarkan ID
    public function destroy($id)
    {
        try {
            $user = Auth::user();
            if (!$user) {
                return response()->json(['message' => 'Unauthorized'], 401);
            }

            $data = PregnancyCalculator::where('user_id', $user->id)->findOrFail($id);
            $data->delete();

            return response()->json(['message' => 'Data berhasil dihapus']);
        } catch (\Exception $e) {
            Log::error('❌ Gagal hapus HPL:', ['error' => $e->getMessage()]);
            return response()->json([
                'message' => 'Gagal menghapus data',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
