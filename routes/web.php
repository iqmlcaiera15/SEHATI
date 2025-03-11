<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DeteksiController;
use App\Http\Controllers\AirQualityController;
use App\Http\Controllers\CatatanController;
use App\Http\Controllers\PostpartumController;
use App\Http\Controllers\KomunitasController;



#Air Quality
Route::get('/kualitasudara', [AirQualityController::class, 'index']);


#Komunitas
Route::get('/komunitas', [KomunitasController::class, 'index']);
Route::post('/komunitas/add', [KomunitasController::class, 'store']);
Route::get('/komunitas/history', [KomunitasController::class, 'history']);
Route::delete('/komunitas/history/deleteAll', [KomunitasController::class, 'deleteAll']);
Route::delete('/komunitas/history/{id}', [KomunitasController::class, 'deleteById']);

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

#Postpartum Recovery Tracker 
Route::get('/Recovery', [DeteksiController::class, 'index']);
Route::get('/Recovery/history', [DeteksiController::class, 'histindex']);

#Saran Makanan
Route::get('/Recovery', [DeteksiController::class, 'index']);
Route::get('/Recovery/history', [DeteksiController::class, 'histindex']);

Route::get('/home', [HomeProfileController::class, 'home']);


#TOKEN
Route::get('token', function () {
    return csrf_token();
});


Route::get('/', function () {
    return view('welcome');
});