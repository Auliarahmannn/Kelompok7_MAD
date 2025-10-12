<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OrderItems extends Model
{
    //
    protected $table = 'order_items';
    protected $fillable = [
        'order_id',
        'product_id',
        'jumlah',
        'harga',
    ];
    public $timestamps = false;

    // public function Customer(){
    //     return $this->belongsTo(Customers:: class, 'customer_id');
    // }
}
