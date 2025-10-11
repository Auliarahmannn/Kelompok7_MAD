<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Customers;

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

    public function Customer(){
        return $this->belongsTo(Customers:: class, 'customer_id');
    }
}
