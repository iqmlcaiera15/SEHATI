<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('deteksipenyakit', function (Blueprint $table) {
            $table->id('deteksi_id'); 
            $table->string('nama');
            $table->integer('umur'); // Ubah menjadi integer jika data umur berupa angka
            $table->integer('bmi');
            $table->integer('tekanan_darah');
            $table->integer('hemoglobin');
            $table->string('hasil_deteksi')->nullable(); 
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('deteksipenyakit'); // Perbaiki nama tabel di sini
    }
};
