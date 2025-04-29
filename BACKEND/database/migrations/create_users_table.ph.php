<?php

// use Illuminate\Database\Migrations\Migration;
// use Illuminate\Database\Schema\Blueprint;
// use Illuminate\Support\Facades\Schema;

// class CreateUsersTable extends Migration
// {
//     /**
//      * Run the migrations.
//      */
//     public function up(): void
//     {
//         Schema::create('users', function (Blueprint $table) {
//             $table->id(); // Primary key
//             $table->string('name'); // Nama pengguna
//             $table->string('email')->unique(); // Email unik
//             $table->timestamp('email_verified_at')->nullable(); // Waktu verifikasi email
//             $table->string('password'); // Password
//             $table->rememberToken(); // Token untuk fitur "remember me"
//             $table->timestamps(); // created_at dan updated_at
//         });
//     }

//     /**
//      * Reverse the migrations.
//      */
//     public function down(): void
//     {
//         Schema::dropIfExists('users');
//     }
// }
