<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use App\Models\PrediksiDepresi;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('skorepds', function (Blueprint $table) {
            $table->id();
            $table->foreignId('prediksi_depresi_id')
                  ->constrained('prediksi_depresi')
                  ->onDelete('cascade');
            $table->json('answers');
            $table->integer('score'); // total skor EPDS
            $table->string('hasil_epds')->nullable(); // status depresi (optional)
            $table->timestamps();
        });
    }

    public function prediksi()
    {
        return $this->belongsTo(PrediksiDepresi::class, 'prediksi_depresi_id');
    }


    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('skorepds');
    }
};
