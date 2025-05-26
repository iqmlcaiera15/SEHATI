<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;
use App\Models\Icon; 
use Illuminate\Support\Facades\Auth;

class UserController extends Controller
{
    public function isidata(Request $request)
    {   
        try {
            // Get user from JWT token
            $userId = auth()->id();
            
            if (!$userId) {
                return response()->json(['message' => 'Unauthorized'], 401);
            }
            
            // Log the incoming request for debugging
            Log::info('Request data:', $request->all());
            
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
                return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
            }

            // Cari user berdasarkan ID dari token JWT
            $user = User::find($userId);

            if (!$user) {
                return response()->json(['message' => 'User tidak ditemukan'], 404);
            }

            // Log yang akan diupdate
            Log::info('Updating user ID: ' . $userId);
            
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
            
        } catch (\Exception $e) {
            // Log the error for debugging
            Log::error('Error in isidata: ' . $e->getMessage());
            Log::error($e->getTraceAsString());
            
            return response()->json([
                'message' => 'Terjadi kesalahan pada server',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function updateSelectedIcon(Request $request)
    {
        $request->validate([
            'icon_id' => 'required|integer|exists:icons,id', // Pastikan icon_id ada di tabel icons
        ]);

        /** @var \App\Models\User $user */
        $user = Auth::user();

        if (!$user) {
            return response()->json(['success' => false, 'message' => 'User not authenticated.'], 401);
        }

        $user->selected_icon_id = $request->icon_id;
        $user->save();

        // Load relasi selectedIcon untuk disertakan dalam response
        $user->load('selectedIcon');

        // Jika menggunakan API Resource untuk User:
        // return new UserResource($user);

        return response()->json([
            'success' => true,
            'message' => 'Icon selected successfully.',
            'data' => $user // Mengembalikan data user yang sudah terupdate beserta ikonnya
        ]);
    }

    /**
     * Get the authenticated user's profile including the selected icon.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function profile(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();

        if (!$user) {
            return response()->json(['success' => false, 'message' => 'User not authenticated.'], 401);
        }

        // Load relasi selectedIcon untuk disertakan dalam response
        $user->load('selectedIcon');

        // Jika menggunakan API Resource untuk User:
        // return new UserResource($user);

        return response()->json([
            'success' => true,
            'data' => $user
        ]);
    }
}