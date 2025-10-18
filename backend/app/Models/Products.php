<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Products extends Model
{
    protected $table = 'products';
    protected $fillable = [
        'nama_produk',
        'deskripsi',
        'harga',
        'stok',
        'foto',
    ];

    public $timestamps = false;

    public function orderItems()
    {
        return $this->hasMany(OrderItems::class, 'product_id');
    }
}
