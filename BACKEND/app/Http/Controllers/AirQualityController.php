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


    #Code jika IP sudah public
    public function index(Request $request)
    {
        try {
            $ip = $request->input('ip', $request->ip());
    
            $data = $this->airVisualService->getNearestCityData($ip);
    
            if (!$data) {
                return response()->json([
                    'message' => 'Data kualitas udara tidak ditemukan.',
                ], 404);
            }
    
            return response()->json($data);
    
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Gagal mengambil data kualitas udara.',
                'error' => $e->getMessage(), // Untuk debug, bisa dihapus di production
            ], 500);
        }
    }
      
}

