<?php

use App\Http\Controllers\PaymentMethodController;
use App\Http\Controllers\ProductController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::get('/products', [ProductController::class, 'index']);
//paymen method
Route::get('/payment_method', [PaymentMethodController::class, 'index']);
