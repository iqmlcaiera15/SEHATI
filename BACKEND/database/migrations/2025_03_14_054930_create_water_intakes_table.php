<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        Schema::create('water_intakes', function (Blueprint $table) {
            $table->id('water_intake_id');
            $table->integer('jumlah_ml')->default(250); // Set default ke 250 ml
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('water_intakes');
    }
};
