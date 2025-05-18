<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class UserController extends Controller
{
    public function isidata(Request $request)
    {   
        // Mendapatkan user dari JWT token
        $userId = auth()->id();
        
        if (!$userId) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }
        
        // Validasi data yang masuk (tanpa validasi user_id)
        $validator = Validator::make($request->all(), [
            'tanggal_lahir' => 'nullable|date',
            'usia' => 'nullable|integer',
            'alamat' => 'nullable|string',
            'nomor_telepon' => 'nullable|string|max:20',
            'pendidikan_terakhir' => 'nullable|string|max:255',
            'pekerjaan' => 'nullable|string|max:255',
            'golongan_darah' => 'nullable|string|max:5',
            'nama_suami' => 'nullable|string|max:255',
            'telepon_suami' => 'nullable|string|max:20',
            'usia_suami' => 'nullable|integer',
            'pekerjaan_suami' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Cari user berdasarkan ID dari token JWT
        $user = User::find($userId);

        if (!$user) {
            return response()->json(['message' => 'User tidak ditemukan'], 404);
        }

        // Update data user yang sudah ada
        $user->update([
            'tanggal_lahir' => $request->tanggal_lahir,
            'usia' => $request->usia,
            'alamat' => $request->alamat,
            'nomor_telepon' => $request->nomor_telepon,
            'pendidikan_terakhir' => $request->pendidikan_terakhir,
            'pekerjaan' => $request->pekerjaan,
            'golongan_darah' => $request->golongan_darah,
            'nama_suami' => $request->nama_suami,
            'telepon_suami' => $request->telepon_suami,
            'usia_suami' => $request->usia_suami,
            'pekerjaan_suami' => $request->pekerjaan_suami,
        ]);

        return response()->json([
            'message' => 'Data ibu hamil berhasil diperbarui!',
            'data' => $user
        ], 200);
    }
}