<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('fetal_monitorings', function (Blueprint $table) {
            $table->id();
            $table->string('nama_calon_bayi');
            $table->float('berat_ibu');
            $table->date('hpht');
            $table->date('hpl');
            $table->boolean('bayi_kembar')->default(false);
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('fetal_monitorings');
    }
};
