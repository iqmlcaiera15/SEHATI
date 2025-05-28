<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pregnancy_calculators', function (Blueprint $table) {
            $table->id();

            // 🔹 Relasi ke user (nullable untuk testing tanpa login)
            $table->unsignedBigInteger('user_id')->nullable();
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');

            // 🔹 Data kehamilan
            $table->date('hpht'); // Hari Pertama Haid Terakhir
            $table->date('hpl');  // Hari Perkiraan Lahir

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pregnancy_calculators');
    }
};
