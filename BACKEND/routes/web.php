<?php
use Illuminate\Support\Facades\Route;


#TOKEN
Route::get('token', function () {
    return csrf_token();
});


Route::get('/', function () {
    return view('welcome');
});