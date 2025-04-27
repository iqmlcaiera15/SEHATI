<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('skorepds', function (Blueprint $table) {
            // Drop foreign key constraint dulu
            $table->dropForeign(['user_id']);
            
            // Baru drop kolomnya
            $table->dropColumn('user_id');
        });
    }

    public function down(): void
    {
        Schema::table('skorepds', function (Blueprint $table) {
            $table->unsignedBigInteger('user_id')->nullable();

            // Add foreign key lagi kalau di-rollback
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });
    }
};
