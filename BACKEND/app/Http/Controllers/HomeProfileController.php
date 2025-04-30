<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class HomeProfileController extends Controller
{
    public function home()
    {
        $CatatanKunjungan = CatatanKunjungan::all();

        return response()->json([
            'CatatanKunjungan' => $CatatanKunjungan
        ]);
    }
}
