<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DeteksiController;
use App\Http\Controllers\PrediksiDepresiController;
use App\Http\Controllers\RekomendasiMakananController;
use App\Http\Controllers\AirQualityController;
use App\Http\Controllers\KickCounterController;
use App\Http\Controllers\SkorEpdsController;

#Air Quality
Route::get('/KualitasUdara', [AirQualityController::class, 'index']);


#Deteksi Penyakit
Route::get('/Deteksi/History', [DeteksiController::class, 'index']);
Route::post('/Deteksi', [DeteksiController::class, 'store']);
Route::delete('/deteksi/History/DeleteAll', [DeteksiController::class, 'deleteAll']);
Route::delete('/deteksi/History/{id}', [DeteksiController::class, 'deleteById']);

#Prediksi Depresi
Route::get('/prediksidepresi', [PrediksiDepresiController::class, 'index']);
Route::post('/prediksidepresi', [PrediksiDepresiController::class, 'store']);
Route::get('/prediksidepresi/{id}', [PrediksiDepresiController::class, 'show']);
Route::delete('/prediksidepresi/delete/{id}', [PrediksiDepresiController::class, 'deletebyID']);

#EPDS
Route::post('/epds', [SkorEpdsController::class, 'store']);
Route::get('/epds', [SkorEpdsController::class, 'index']);
Route::get('/epds/{id}', [SkorEpdsController::class, 'show']);

#Rekomendasi Makanan
Route::get('/rekomendasimakanan', [RekomendasiMakananController::class, 'index']);
Route::get('/rekomendasimakanan/{id}', [RekomendasiMakananController::class, 'show']);

#Kick Counter
Route::get('/kick-counter', [KickCounterController::class, 'index']);
Route::post('/kick-counter', [KickCounterController::class, 'store']);


Route::get('token', function () {
    return csrf_token();
});

Route::get('/', function () {
    return view('welcome');
});