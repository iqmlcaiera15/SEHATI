<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePregnancyCalculatorsTable extends Migration
{
    public function up()
    {
        Schema::create('pregnancy_calculators', function (Blueprint $table) {
            $table->id();
            $table->date('hpht'); // Hari Pertama Haid Terakhir
            $table->date('hpl');  // Hari Perkiraan Lahir (otomatis dihitung)
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('pregnancy_calculators');
    }
}
