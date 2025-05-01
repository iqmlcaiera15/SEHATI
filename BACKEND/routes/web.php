<?php
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\DeteksiController;
use App\Http\Controllers\AirQualityController;
use App\Http\Controllers\CatatanController;
use App\Http\Controllers\PostpartumController;
use App\Http\Controllers\KomunitasController;
use App\Http\Controllers\PrediksiDepresiController;
use App\Http\Controllers\RekomendasiMakananController;
use App\Http\Controllers\KickCounterController;
use App\Http\Controllers\SkorEpdsController;
use App\Http\Controllers\PredictionController;
use App\Http\Controllers\WaterIntakeController;
use App\Http\Controllers\PregnancyCalculatorController;
use App\Http\Controllers\FetalMonitoringController;


#Air Quality
Route::get('/kualitasudara', [AirQualityController::class, 'getCityData']);


#Komunitas
Route::get('/komunitas', [KomunitasController::class, 'index']);
Route::post('/komunitas/add', [KomunitasController::class, 'store']);
Route::get('/komunitas/history', [KomunitasController::class, 'history']);
Route::get('/komunitas/latest', [KomunitasController::class, 'indexlatest']);
Route::delete('/komunitas/history/deleteAll', [KomunitasController::class, 'deleteAll']);
Route::delete('/komunitas/history/{id}', [KomunitasController::class, 'deleteById']);

#Catatan Kunjungan
Route::get('/catatan/history', [CatatanController::class, 'index']);
Route::post('/catatan', [CatatanController::class, 'store']);
Route::delete('/catatan/history/deleteAll', [CatatanController::class, 'deleteAll']);
Route::delete('/catatan/history/{id}', [CatatanController::class, 'deleteById']);

#Deteksi Penyakit
Route::get('/deteksi/history', [DeteksiController::class, 'index']);
Route::get('/deteksi/latest', [DeteksiController::class, 'indexlatest']);
Route::post('/deteksi/store', [DeteksiController::class, 'store']);
Route::delete('/deteksi/history/deleteAll', [DeteksiController::class, 'deleteAll']);
Route::delete('/deteksi/history/{id}', [DeteksiController::class, 'deleteById']);

#Postpartum Recovery Tracker
Route::get('/Recovery', [DeteksiController::class, 'index']);
Route::get('/Recovery/history', [DeteksiController::class, 'histindex']);

#Saran Makanan
Route::get('/Recovery', [DeteksiController::class, 'index']);
Route::get('/Recovery/history', [DeteksiController::class, 'histindex']);

Route::get('/home', [HomeProfileController::class, 'home']);

#Prediksi Depresi
Route::get('/prediksidepresi', [PrediksiDepresiController::class, 'index']);
Route::post('/prediksidepresi/store', [PrediksiDepresiController::class, 'store']);
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
Route::post('/kick-counter/store', [KickCounterController::class, 'store']);

#Prediksi Metode Persalinan
Route::get('/predictions', [PredictionController::class, 'index']);
Route::get('/predictions/{id}', [PredictionController::class, 'show']);
Route::post('/predictions', [PredictionController::class, 'store']);
Route::put('/predictions/{id}', [PredictionController::class, 'update']);
Route::delete('/predictions/{id}', [PredictionController::class, 'destroy']);

#Water Intake
Route::post('/water-intake', [WaterIntakeController::class, 'store']);
Route::get('/water-intake', [WaterIntakeController::class, 'index']);
Route::get('/water-intake/{id}', [WaterIntakeController::class, 'show']);
Route::put('/water-intake/{id}', [WaterIntakeController::class, 'update']);
Route::delete('/water-intake/{id}', [WaterIntakeController::class, 'destroy']);

#Kalkulator HPL
Route::get('pregnancy-calculators', [PregnancyCalculatorController::class, 'index']);
Route::post('pregnancy-calculators', [PregnancyCalculatorController::class, 'store']);
Route::get('pregnancy-calculators/{id}', [PregnancyCalculatorController::class, 'show']);
Route::put('pregnancy-calculators/{id}', [PregnancyCalculatorController::class, 'update']);
Route::delete('pregnancy-calculators/{id}', [PregnancyCalculatorController::class, 'destroy']);


#Fetal Monitoring
Route::get('fetal-monitorings', [FetalMonitoringController::class, 'index']);
Route::post('fetal-monitorings', [FetalMonitoringController::class, 'store']);
Route::get('fetal-monitorings/{id}', [FetalMonitoringController::class, 'show']);
Route::put('fetal-monitorings/{id}', [FetalMonitoringController::class, 'update']);
Route::delete('fetal-monitorings/{id}', [FetalMonitoringController::class, 'destroy']);


#Login Register
Route::post('login', [AuthController::class, 'login']);


#TOKEN
Route::get('token', function () {
    return csrf_token();
});

#Home
Route::get('/', function () {
    return view('welcome');
});
