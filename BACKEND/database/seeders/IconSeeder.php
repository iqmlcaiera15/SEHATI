<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Icons;

class IconSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Icons::create([
            'name' => 'Wajah Senyum',
            'type' => 'material',
            'data' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/rekomenmakanan/ikan_salmon.jpg' 
        ]);

        Icons::create([
            'name' => 'Hati',
            'type' => 'material',
            'data' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/rekomenmakanan/ikan_salmon.jpg' 
        ]);

        Icons::create([
            'name' => 'Bintang',
            'type' => 'material',
            'data' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/rekomenmakanan/ikan_salmon.jpg' 
        ]);

        Icons::create([
            'name' => 'Rumah',
            'type' => 'material',
            'data' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/rekomenmakanan/ikan_salmon.jpg' 
        ]);

        Icons::create([
            'name' => 'Avatar Pria 1',
            'type' => 'url',
            'data' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/rekomenmakanan/ikan_salmon.jpg' // Bisa sama dengan identifier atau path lokal
        ]);

         Icons::create([
            'name' => 'Kucing SVG',
            'type' => 'svg_string',
            'data' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/rekomenmakanan/ikan_salmon.jpg' 
        ]);
    }
}