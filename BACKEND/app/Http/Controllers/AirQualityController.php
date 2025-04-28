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
   
    $ip = $request->input('ip', $request->ip());
    
    dd($ip);
  
    $data = $this->airVisualService->getNearestCityData($ip);
    return response()->json($data);
    }
    
}

