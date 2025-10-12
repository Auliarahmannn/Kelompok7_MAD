<?php

use App\Http\Controllers\CustomersController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\OrderItemsController;
use App\Http\Controllers\OrdersController;
use App\Http\Controllers\PaymentMethodController;
use App\Http\Controllers\PaymentsController;
use App\Http\Controllers\ProductController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// orders
Route::get('/orders', [OrdersController::class, 'index']);
Route::get('/orders/{id}', [OrdersController::class, 'show']);

// order items
Route::get('/order-items', [OrderItemsController::class, 'index']);
Route::post('/order-items', [OrderItemsController::class, 'store']);

// products
Route::get('/products', [ProductController::class, 'index']);
Route::get('/products/{id}', [ProductController::class, 'show']);

// payments 
Route::get('/payments', [PaymentsController::class, 'index']);
Route::get('/payments/{id}', [PaymentsController::class, 'show']);

// payment method
Route::get('/payment_method', [PaymentMethodController::class, 'index']);

// customers
Route::get('/customers', [CustomersController::class, 'index']);
