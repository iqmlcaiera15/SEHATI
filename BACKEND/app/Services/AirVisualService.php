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
    
        $response = Http::get("http://api.airvisual.com/v2/stations?city=Bandung&state=West%20Java&country=Indonesia&key=f3d3ed29-2c0f-4957-a49b-d6c9b850a1cd", [
            'city' => $city,
            'state' => $state,
            'country' => $country,
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
