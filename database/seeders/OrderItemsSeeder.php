<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\OrderItems;

class OrderItemsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        //
        OrderItems::create([
            'order_id' => 1,
            'product_id' => 1,
            'jumlah' => 2,
            'harga' => 250000,
        ]);

        OrderItems::create([
            'order_id' => 1,
            'product_id' => 2,
            'jumlah' => 1,
            'harga' => 450000,
        ]);
    }
}
