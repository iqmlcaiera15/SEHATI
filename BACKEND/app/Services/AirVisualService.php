<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

class AirVisualService
{
    /**
     * Get nearest city data based on IP.
     *
     * @param string $ip
     * @return array
     */
    public function index($ip)
    {
        $apiKey = config('services.airvisual.key');

        \Log::info('Making request to AirVisual API', [
            'ip' => $ip,
            'api_key' => $apiKey,
        ]);
    
        $response = Http::withHeaders([
        ])->get("http://api.airvisual.com/v2/nearest_city", [
            'key' => $apiKey,
        ]);
    
        if ($response->successful()) {
            return $response->json();
        }
    
        // Log error details
        \Log::error('AirVisual API Error', [
            'status' => $response->status(),
            'body' => $response->body(),
        ]);
    
        return [
            'error' => 'Unable to fetch data from AirVisual API',
            'status' => $response->status(),
        ];
    }
}


