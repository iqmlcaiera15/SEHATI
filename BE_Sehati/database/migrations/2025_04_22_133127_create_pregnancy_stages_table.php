<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('pregnancy_stages', function (Blueprint $table) {
            $table->id();
            $table->integer('minggu_ke')->unique();
            $table->string('bentuk_janin');
            $table->string('panjang_badan')->nullable();
            $table->string('berat_badan')->nullable();
            $table->text('perkembangan');
            $table->text('rekomendasi');
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('pregnancy_stages');
    }
};
