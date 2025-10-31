<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Orders extends Model
{
    protected $table = 'orders';
    protected $fillable = [
        'customer_id',
        'tanggal_pesan',
        'total_harga',
        'status',
    ];

    public $timestamps = false;

    public function customer()
    {
        return $this->belongsTo(Customers::class, 'customer_id');
    }

    public function orderItems()
    {
        return $this->hasMany(OrderItems::class, 'order_id');
    }

    public function payment()
    {
        return $this->hasOne(Payments::class, 'order_id');
    }
}
