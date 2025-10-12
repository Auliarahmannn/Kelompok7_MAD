<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Payments extends Model
{
    protected $table = 'payments';
    protected $fillable = [
        'order_id',
        'payment_method_id',
        'jumlah_bayar',
        'tanggal_bayar',
        'status',
    ];

    public $timestamps = false;
}
