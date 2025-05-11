<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\HomeController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

// Authentication Routes (if you're using Laravel's default auth)
Auth::routes();

// Custom Registration Routes
Route::get('/register/bidan', [RegisterController::class, 'showBidanRegistrationForm'])->name('register.bidan.form');
Route::post('/register/bidan', [RegisterController::class, 'registerBidan'])->name('register.bidan');

Route::get('/register/dinkes', [RegisterController::class, 'showDinkesRegistrationForm'])->name('register.dinkes.form');
Route::post('/register/dinkes', [RegisterController::class, 'registerDinkes'])->name('register.dinkes');

// Protected Routes for Bidan - Using the check.role middleware
Route::middleware(['auth'])->prefix('bidan')->group(function () {
    Route::get('/dashboard', function () {
        return view('bidan.dashboard');
    })->name('bidan.dashboard');
    

    // Route::get('/dashboard', [HomeController::class, 'index'])->name('bidan.dashboard');
    // Add more bidan routes here
});

Route::get('bidan/dashboard', [HomeController::class, 'index'])->name('bidan.dashboard');


// Protected Routes for Dinkes - Using the check.role middleware
Route::middleware(['auth'])->prefix('dinkes')->group(function () {
    // Route::get('/dashboard', function () {
    //     return view('dinkes.dashboard');
    // })->name('dinkes.dashboard');
    
    // Add more dinkes routes here
});

Route::get('dinkes/dashboard', [HomeController::class, 'index_dinkes'])->name('dinkes.dashboard');

// Home route (redirect based on role)
Route::get('/home', function() {
    if (auth()->check()) {
        if (auth()->user()->role === 'bidan') {
            return redirect()->route('bidan.dashboard');
        } elseif (auth()->user()->role === 'dinkes') {
            return redirect()->route('dinkes.dashboard');
        }
    }
    
    return redirect()->route('login');
})->name('home');