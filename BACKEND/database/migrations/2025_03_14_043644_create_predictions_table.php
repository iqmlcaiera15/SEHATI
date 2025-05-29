<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('predictions', function (Blueprint $table) {
            $table->id();

            // 🔐 Relasi wajib ke tabel users
            $table->foreignId('user_id')
                  ->constrained('users')
                  ->onDelete('cascade');

            // 🧠 Input untuk prediksi
            $table->integer('usia_ibu');
            $table->string('tekanan_darah');              // Ex: normal, rendah, tinggi
            $table->string('riwayat_persalinan');         // Ex: tidak ada, normal, caesar
            $table->string('posisi_janin');               // Ex: normal, lintang, sungsang
            $table->string('riwayat_kesehatan_ibu')->default('normal');
            $table->string('kondisi_kesehatan_janin')->default('normal');

            // ✅ Output prediksi dari model
            $table->string('metode_persalinan');          // Ex: normal / caesar
            $table->text('faktor')->nullable();           // Bisa berisi penjelasan atau JSON

            $table->timestamps(); // created_at dan updated_at
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('predictions');
    }
};
