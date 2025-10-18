<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Customers extends Model
{
    protected $table = 'customers';
    protected $fillable = [
        'name',
        'email',
        'phone',
        'address',
        'user_id'
    ];

    public $timestamps = false;
    
    public function orders()
    {
        return $this->hasMany(Orders::class, 'customer_id');
    }

    public function User(){
        return $this->belongsTo(User::class);
    }
}
