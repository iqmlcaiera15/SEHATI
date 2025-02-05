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
        Schema::create('skrining_depresi', function (Blueprint $table) {
            $table->id('user_id'); 
            $table->integer('whooley_1');
            $table->integer('whooley_2');
            $table->integer('whooley_result');
            $table->integer('epds_score');
            $table->integer('umur');
            $table->integer('jumlah_kelahiran');
            $table->integer('jumlah_keguguran');
            $table->string('status_bekerja');
            $table->integer('tanggal_evaluasi');
            $table->string('depression_status')->nullable(); 
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
