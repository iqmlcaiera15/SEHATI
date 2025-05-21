<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('predictions', function (Blueprint $table) {
            $table->id();
            $table->integer('usia_ibu');
            $table->string('tekanan_darah');
            $table->string('riwayat_persalinan');
            $table->string('posisi_janin');
            $table->string('riwayat_kesehatan_ibu')->nullable();
            $table->string('kondisi_kesehatan_janin')->nullable();
            $table->string('metode_persalinan'); // ✅ HANYA metode_persalinan
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('predictions');
    }
};
