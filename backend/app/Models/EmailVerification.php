<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EmailVerification extends Model
{
    use HasFactory;

    protected $table = 'email_verifications';

    // Field yang boleh diisi
    protected $fillable = [
        'email',
        'otp',
        'expires_at',
    ];

    // Otomatis ubah expires_at jadi instance Carbon (datetime)
    protected $dates = [
        'expires_at',
    ];

    // Opsional: menandai bahwa model ini tidak punya kolom deleted_at
    public $timestamps = true;
}
