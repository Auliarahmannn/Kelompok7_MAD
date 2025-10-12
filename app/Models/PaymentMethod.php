<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PaymentMethod extends Model
{
     protected $table = 'payment_methods';
    protected $fillable = [
        'metode',
        'deskripsi',
    ];

    public $timestamps = false;

    public function payments()
    {
        return $this->hasMany(Payments::class, 'payment_method_id');
    }
}
