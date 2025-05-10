<?php


use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;

// Grup untuk guest (yang belum login)
Route::middleware('guest')->group(function () {

    Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
    // Route Proses Login
    Route::post('/login', [AuthController::class, 'login'])->name('login.post');
    // Route view form register bidan
    Route::get('/register/bidan', function () {
        return view('auth.register-bidan-dinkes', ['role' => 'bidan']);
    })->name('register.bidan');
    
    Route::get('/register/dinkes', function () {
        return view('auth.register-bidan-dinkes', ['role' => 'dinas_kesehatan']);
    })->name('register.dinkes');

    // Route proses register (digunakan bersama)
    Route::post('/register/process', [AuthController::class, 'register'])
        ->name('register.process');
});

// Grup untuk auth (yang sudah login)
Route::middleware('auth')->group(function () {
    // Route setelah registrasi berhasil
    Route::get('/admin/dashboard', [AdminController::class, 'dashboard'])
        ->name('admin.dashboard')
        ->middleware('role:bidan,dinas_kesehatan');
});


// CSRF Token
Route::get('/token', function () {
    return csrf_token();
});

// Welcome
Route::get('/', function () {
    return view('welcome');
});