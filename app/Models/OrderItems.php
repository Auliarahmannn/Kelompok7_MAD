<?php 

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OrderItems extends Model
{
    protected $table = 'order_items';

    protected $fillable = [
        'order_id',
        'product_id',
        'jumlah',
        'harga',
    ];

    public $timestamps = false;

    // Sembunyikan kolom created_at dan updated_at dari hasil JSON/API
    protected $hidden = ['created_at', 'updated_at'];

    
    public function order()
    {
        return $this->belongsTo(Orders::class, 'order_id');
    }

  
    public function product()
    {
        return $this->belongsTo(Products::class, 'product_id');
    }

}
