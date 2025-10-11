<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\OrderItemsController;
use App\Http\Controllers\OrdersController;
use App\Http\Controllers\PaymentMethodController;
use App\Http\Controllers\ProductController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');


// orders
Route::get('/orders', [OrdersController::class, 'index']);
Route::get('/orders/{id}', [OrdersController::class, 'show']);

// order items
Route::get('/order-items', [OrderItemsController::class, 'index']);

// products
Route::get('/products', [ProductController::class, 'index']);

// payment method
Route::get('/payment_method', [PaymentMethodController::class, 'index']);
