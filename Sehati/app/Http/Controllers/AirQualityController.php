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

    #IP LOCAL dan PostMan
    public function index(Request $request)
    {
    $ip = $request->header('X-Forwarded-For') ?: $request->ip();


    if (strpos($ip, ',') !== false) {
        $ip = explode(',', $ip)[0];
    }

    $data = $this->airVisualService->index($ip);

    return response()->json($data);
    }
    
}

#Code jika IP sudah public
//public function index(Request $request)
// {
//     // Ambil IP dari request atau gunakan IP pengguna secara otomatis
//     $ip = $request->input('ip', $request->ip());
    
//     // Panggil service untuk mendapatkan data kota terdekat
//     $data = $this->airVisualService->getNearestCityData($ip);

//     // Kembalikan response JSON
//     return response()->json($data);
// }