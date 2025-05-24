<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Icon;
use Illuminate\Http\Request;
use App\Http\Resources\IconResource; // Opsional, untuk transformasi data

class IconController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $icons = Icon::all();
        // Jika menggunakan API Resource:
        // return IconResource::collection($icons);

        // Jika tidak:
        return response()->json([
            'success' => true,
            'data' => $icons,
            'message' => 'Icons retrieved successfully.'
        ]);
    }
}