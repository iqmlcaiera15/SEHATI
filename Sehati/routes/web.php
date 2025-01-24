<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DeteksiController;
use App\Http\Controllers\AirQualityController;



#Air Quality
Route::get('/KualitasUdara', [AirQualityController::class, 'index']);


#Deteksi Penyakit
Route::get('/Deteksi/History', [DeteksiController::class, 'index']);
Route::post('/Deteksi', [DeteksiController::class, 'store']);
Route::delete('/deteksi/History/DeleteAll', [DeteksiController::class, 'deleteAll']);
Route::delete('/deteksi/History/{id}', [DeteksiController::class, 'deleteById']);

Route::get('token', function () {
    return csrf_token();
});

Route::get('/', function () {
    return view('welcome');
});