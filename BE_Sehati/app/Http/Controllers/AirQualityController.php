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




    public function getStations(Request $request)
    {
        // Ambil parameter dari query string atau gunakan default
        $city = $request->input('city', 'Bandung');
        $state = $request->input('state', 'West Java');
        $country = $request->input('country', 'Indonesia');
        
        // Dapatkan data stasiun dari AirVisualService
        $data = $this->airVisualService->getStations($city, $state, $country);

        // Return data stasiun dalam format JSON
        return response()->json($data);
    }
}
