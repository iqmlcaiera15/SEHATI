<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\KickCounter;

class KickCounterController extends Controller
{
    
    public function store(Request $request)
    {
        try {
            $request->validate([
                'kick_count' => 'required|integer|min:1',
            ]);
    
            $kickCounter = KickCounter::create([
                'kick_count' => $request->kick_count,
                'recorded_at' => now(),
            ]);
    
            return response()->json([
                'message' => 'Data berhasil disimpan',
                'data' => $kickCounter
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


    public function index()
    {
        $kickCounter = KickCounter::all();

        return response()->json([
            'data' => $kickCounter
        ]);
    }
}
