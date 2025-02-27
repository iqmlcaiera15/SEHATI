<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DeteksiController;
use App\Http\Controllers\PrediksiDepresiController;
use App\Http\Controllers\RekomendasiMakananController;
use App\Http\Controllers\AirQualityController;
use App\Models\PrediksiDepresi;

#Air Quality
Route::get('/KualitasUdara', [AirQualityController::class, 'index']);


#Deteksi Penyakit
Route::get('/Deteksi/History', [DeteksiController::class, 'index']);
Route::post('/Deteksi', [DeteksiController::class, 'store']);
Route::delete('/deteksi/History/DeleteAll', [DeteksiController::class, 'deleteAll']);
Route::delete('/deteksi/History/{id}', [DeteksiController::class, 'deleteById']);

#Prediksi Depresi
Route::get('/skriningdepresi', [PrediksiDepresiController::class, 'index']);
Route::post('/skriningdepresi/whooley', [PrediksiDepresiController::class, 'store']);
Route::get('/skriningdepresi/{id}', [PrediksiDepresiController::class, 'show']);
Route::post('/skriningdepresi/hasilprediksi', [PrediksiDepresiController::class, 'prediksiDepresiHasil']);

#Rekomendasi Makanan
Route::get('/rekomendasimakanan', [RekomendasiMakananController::class, 'index']);
Route::get('/rekomendasimakanan/{id}', [RekomendasiMakananController::class, 'show']);

Route::get('token', function () {
    return csrf_token();
});

Route::get('/', function () {
    return view('welcome');
});