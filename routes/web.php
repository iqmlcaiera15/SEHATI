<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DeteksiController;
use App\Http\Controllers\AirQualityController;
use App\Http\Controllers\CatatanController;



#Air Quality
Route::get('/kualitasudara', [AirQualityController::class, 'index']);


#Catatan Kunjungan
Route::get('/catatan/history', [CatatanController::class, 'index']);
Route::post('/catatan', [CatatanController::class, 'store']);
Route::delete('/catatan/history/deleteAll', [CatatanController::class, 'deleteAll']);
Route::delete('/catatan/history/{id}', [CatatanController::class, 'deleteById']);

#Deteksi Penyakit
Route::get('/deteksi/history', [DeteksiController::class, 'index']);
Route::post('/deteksi', [DeteksiController::class, 'store']);
Route::delete('/deteksi/history/deleteAll', [DeteksiController::class, 'deleteAll']);
Route::delete('/deteksi/history/{id}', [DeteksiController::class, 'deleteById']);

#TOKEN
Route::get('token', function () {
    return csrf_token();
});

Route::get('/', function () {
    return view('welcome');
});