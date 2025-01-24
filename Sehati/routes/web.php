<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DeteksiController;

Route::get('/Deteksi/History', [DeteksiController::class, 'index']);
Route::post('/Deteksi', [DeteksiController::class, 'store']);

Route::get('token', function () {
    return csrf_token();
});

Route::get('/', function () {
    return view('welcome');
});