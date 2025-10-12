<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Orders extends Model
{
    //
    protected $table = 'orders';
    protected $fillable = [
        'customer_id',
        'tanggal_pesan',
        'total',
        'status',
    ];

    public $timestamps = false;

    public function Customers(){
        return $this->belongsTo(Customers:: class, 'customer_id');
    }
}
