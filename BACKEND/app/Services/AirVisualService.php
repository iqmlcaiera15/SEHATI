<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

class AirVisualService
{
    /**
     * Get the list of supported stations in a specified city.
     *
     * @param string $city
     * @param string $state
     * @param string $country
     * @return array
     */
    public function getStations($city, $state, $country)
    {
        $apiKey = config('services.airvisual.key');

        \Log::info('Making request to AirVisual API to get stations', [
            'city' => $city,
            'state' => $state,
            'country' => $country,
            'api_key' => $apiKey,
        ]);
    
        $response = Http::get("http://api.airvisual.com/v2/stations", [
            'key' => $apiKey,
            'city' => 'Bandung',
            'state' => 'West Java',
            'country' => 'Indonesia',
        ]);
        
        \Log::info('AirVisual API Response:', [
            'status' => $response->status(),
            'body' => $response->body(), // Tambahkan ini untuk melihat detail error
        ]);
        
        if ($response->successful()) {
            return $response->json();
        } else {
            return [
                'error' => 'Unable to fetch data from AirVisual API',
                'status' => $response->status(),
                'body' => $response->body(),  // Berikan response body agar dapat mendiagnosis error
            ];
        }
        
    }
}
