<?php

namespace App\Http\Controllers;

use App\Services\AirVisualService;
use Illuminate\Http\Request;


class AirQualityController extends Controller
{
    protected $airVisualService;

    public function __construct(AirVisualService $airVisualService)
    {
        $this->airVisualService = $airVisualService;
    }

    /**
     * Menampilkan data kualitas udara berdasarkan IP address.
     */
    public function index(Request $request)
    {
        try {
            $ip = $request->input('ip', $request->ip());

            $data = $this->airVisualService->getNearestCityData($ip);

            if (empty($data)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data kualitas udara tidak ditemukan.',
                ], 404);
            }

            return response()->json([
                'success' => true,
                'data' => $data,
            ], 200);

        } catch (\Throwable $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data kualitas udara.',
                'error' => env('APP_DEBUG') ? $e->getMessage() : 'Terjadi kesalahan.', // Lebih aman di production
            ], 500);
        }
    }
}
