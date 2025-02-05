<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DeteksiController;
use App\Http\Controllers\SkriningDepresiController;
use App\Http\Controllers\AirQualityController;
use App\Models\SkriningDepresi;

#Air Quality
Route::get('/KualitasUdara', [AirQualityController::class, 'index']);


#Deteksi Penyakit
Route::get('/Deteksi/History', [DeteksiController::class, 'index']);
Route::post('/Deteksi', [DeteksiController::class, 'store']);
Route::delete('/deteksi/History/DeleteAll', [DeteksiController::class, 'deleteAll']);
Route::delete('/deteksi/History/{id}', [DeteksiController::class, 'deleteById']);

#Skrining Depresi
Route::get('/skriningdepresi//', [SkriningDepresiController::class, 'index']);
Route::post('/skriningdepresi/whooley', [SkriningDepresiController::class, 'store']);
Route::post('/skriningdepresi/epds/{id}', [SkriningDepresiController::class, 'storeEPDS']);
Route::get('/skriningdepresi/{id}', [SkriningDepresiController::class, 'show']);
Route::post('/skriningdepresi/hasilprediksi', [SkriningDepresiController::class, 'prediksiDepresiHasil']);


Route::get('token', function () {
    return csrf_token();
});

Route::get('/', function () {
    return view('welcome');
});