<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateKomentarKomunitasTable extends Migration
{
    public function up()
    {
        Schema::create('komenkomunitas', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('post_id');
            // $table->string('user_id'); 
            $table->string('komentar');
            $table->timestamps();

            $table->foreign('post_id')->references('post_id')->on('komunitas')->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::dropIfExists('komenkomunitas');
    }
}

