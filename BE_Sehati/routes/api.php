<?php

// use Illuminate\Support\Facades\Route;
// use App\Http\Controllers\DeteksiController;
// use App\Http\Controllers\AirQualityController;
// use App\Http\Controllers\CatatanController;
// use App\Http\Controllers\PostpartumController;
// use App\Http\Controllers\KomunitasController;

// use App\Http\Controllers\PrediksiDepresiController;
// use App\Http\Controllers\RekomendasiMakananController;
// use App\Http\Controllers\KickCounterController;
// use App\Http\Controllers\SkorEpdsController;




// #Air Quality
// Route::get('/kualitasudara', [AirQualityController::class, 'index']);


// #Komunitas
// Route::get('/komunitas', [KomunitasController::class, 'index']);
// Route::post('/komunitas/add', [KomunitasController::class, 'store']);
// Route::get('/komunitas/history', [KomunitasController::class, 'history']);
// Route::delete('/komunitas/history/deleteAll', [KomunitasController::class, 'deleteAll']);
// Route::delete('/komunitas/history/{id}', [KomunitasController::class, 'deleteById']);

// #Catatan Kunjungan
// Route::get('/catatan/history', [CatatanController::class, 'index']);
// Route::post('/catatan', [CatatanController::class, 'store']);
// Route::delete('/catatan/history/deleteAll', [CatatanController::class, 'deleteAll']);
// Route::delete('/catatan/history/{id}', [CatatanController::class, 'deleteById']);

// #Deteksi Penyakit
// Route::get('/deteksi/history', [DeteksiController::class, 'index']);
// Route::post('/deteksi/store', [DeteksiController::class, 'store']);
// Route::delete('/deteksi/history/deleteAll', [DeteksiController::class, 'deleteAll']);
// Route::delete('/deteksi/history/{id}', [DeteksiController::class, 'deleteById']);

// #Postpartum Recovery Tracker 
// Route::get('/Recovery', [DeteksiController::class, 'index']);
// Route::get('/Recovery/history', [DeteksiController::class, 'histindex']);

// #Saran Makanan
// Route::get('/Recovery', [DeteksiController::class, 'index']);
// Route::get('/Recovery/history', [DeteksiController::class, 'histindex']);
// Route::get('/home', [HomeProfileController::class, 'home']);

// #Prediksi Depresi
// Route::get('/prediksidepresi', [PrediksiDepresiController::class, 'index']);
// Route::post('/prediksidepresi', [PrediksiDepresiController::class, 'store']);
// Route::get('/prediksidepresi/{id}', [PrediksiDepresiController::class, 'show']);
// Route::delete('/prediksidepresi/delete/{id}', [PrediksiDepresiController::class, 'deletebyID']);


// #EPDS
// Route::post('/epds', [SkorEpdsController::class, 'store']);
// Route::get('/epds', [SkorEpdsController::class, 'index']);
// Route::get('/epds/{id}', [SkorEpdsController::class, 'show']);

// #Rekomendasi Makanan
// Route::get('/rekomendasimakanan', [RekomendasiMakananController::class, 'index']);
// Route::get('/rekomendasimakanan/{id}', [RekomendasiMakananController::class, 'show']);

// #Kick Counter
// Route::get('/kick-counter', [KickCounterController::class, 'index']);
// Route::post('/kick-counter', [KickCounterController::class, 'store']);




// #TOKEN
// Route::get('token', function () {
//     return csrf_token();
// });


// Route::get('/', function () {
//     return view('welcome');
// });

