<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DeteksikController;

Route::post('/Deteksi', [DeteksiController::class, 'store']);

Route::get('/', function () {
    return view('welcome');
});