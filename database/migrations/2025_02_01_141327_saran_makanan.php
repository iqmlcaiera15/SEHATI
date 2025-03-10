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
        Schema::create('saran_makanan', function (Blueprint $table) {
            $table->id('makanan_id'); 
            $table->string('kategori');
            $table->string('gambar')->nullable(); 
            $table->string('nama_makanan');
            $table->string('deskripsi');
            $table->string('cocok');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        //
    }
};
