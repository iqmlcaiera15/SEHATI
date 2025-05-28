<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        Schema::create('water_intakes', function (Blueprint $table) {
            $table->id();

            // Nullable untuk testing tanpa user login
            $table->unsignedBigInteger('user_id')->nullable();
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');

            // Jumlah konsumsi air dalam mililiter
            $table->integer('jumlah_ml')->default(250);

            // Opsional: Tanggal konsumsi (jika ingin catat per hari)
            $table->date('tanggal')->nullable();

            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('water_intakes');
    }
};
