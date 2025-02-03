<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class SaranMakananSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $Makanans = [
            [
                'service_id' => 1,
                'customer_name' => 'John Doe',
                'customer_phone' => '1234567890',
                'truck_number' => 'AB123CD',
                'fuel_type' => 'Diesel',
                'booking_date' => '2025-01-10',
                'booking_time' => '10:00:00',
                'estimated_total_price' => 150.00,
                'status' => 3,
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now()
            ],
            [
                'service_id' => 2,
                'customer_name' => 'Jane Smith',
                'customer_phone' => '0987654321',
                'truck_number' => 'EF456GH',
                'fuel_type' => 'Petrol',
                'booking_date' => '2025-01-11',
                'booking_time' => '11:00:00',
                'estimated_total_price' => 200.00,
                'status' => 3,
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now()
            ],
            [
                'service_id' => 3,
                'customer_name' => 'Mike Johnson',
                'customer_phone' => '1122334455',
                'truck_number' => 'IJ789KL',
                'fuel_type' => 'Diesel',
                'booking_date' => '2025-01-12',
                'booking_time' => '12:00:00',
                'estimated_total_price' => 250.00,
                'status' => 3,
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now()
            ],
            [
                'service_id' => 4,
                'customer_name' => 'Emily Davis',
                'customer_phone' => '6677889900',
                'truck_number' => 'MN012OP',
                'fuel_type' => 'Petrol',
                'booking_date' => '2025-01-13',
                'booking_time' => '13:00:00',
                'estimated_total_price' => 300.00,
                'status' => 3,
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now()
            ],
            [
                'service_id' => 5,
                'customer_name' => 'Chris Brown',
                'customer_phone' => '4455667788',
                'truck_number' => 'QR345ST',
                'fuel_type' => 'Diesel',
                'booking_date' => '2025-01-14',
                'booking_time' => '14:00:00',
                'estimated_total_price' => 350.00,
                'status' => 3,
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now()
            ],
        ];

        foreach ($Makanans as $Makanan)
        {
            DB::table('saran_makanan')->insert($booking);
        }
    }
}
