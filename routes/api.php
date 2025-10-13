<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\CustomersController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\OrdersController;
use App\Http\Controllers\OrderItemsController;
use App\Http\Controllers\PaymentMethodController;
use App\Http\Controllers\PaymentsController;
use App\Http\Controllers\ProductController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// ==================== ADMIN ROUTES ====================
Route::middleware(['auth:sanctum', 'peran:admin'])->group(function () {
    // Products
    Route::post('/products', [ProductController::class, 'store']);
    Route::put('/products/{id}', [ProductController::class, 'update']);
    Route::delete('/products/{id}', [ProductController::class, 'destroy']);

    // Orders - admin bisa lihat semua order
    Route::get('/orders', [OrdersController::class, 'index']);
    Route::get('/orders/{id}', [OrdersController::class, 'show']);
    Route::delete('/orders/{id}', [OrdersController::class, 'destroy']);

    // Payments
    Route::get('/payments', [PaymentsController::class, 'index']);
    Route::get('/payments/{id}', [PaymentsController::class, 'show']);
    Route::put('/payments/{id}', [PaymentsController::class, 'update']);
    Route::delete('/payments/{id}', [PaymentsController::class, 'destroy']);

    // Payment Methods
    Route::get('/payment_method', [PaymentMethodController::class, 'index']);
    Route::post('/payment_method', [PaymentMethodController::class, 'store']);
    Route::put('/payment_method/{id}', [PaymentMethodController::class, 'update']);
    Route::delete('/payment_method/{id}', [PaymentMethodController::class, 'destroy']);

    // Customers
    Route::get('/customers', [CustomersController::class, 'index']);
    Route::get('/customers/{id}', [CustomersController::class, 'show']);
    Route::delete('/customers/{id}', [CustomersController::class, 'destroy']);
});


// ==================== CUSTOMER ROUTES ====================
Route::middleware(['auth:sanctum', 'peran:customer'])->group(function () {
    // products (customer hanya lihat, tidak bisa edit)
    Route::get('/products', [ProductController::class, 'index']);
    Route::get('/products/{id}', [ProductController::class, 'show']);

    // orders (customer hanya buat & lihat order sendiri)
    Route::get('/orders', [OrdersController::class, 'index']); // di controller filter by user_id
    Route::post('/orders', [OrdersController::class, 'store']);
    Route::get('/orders/{id}', [OrdersController::class, 'show']);

    // order items (biasanya otomatis saat buat order)
    Route::post('/order-items', [OrderItemsController::class, 'store']);
    Route::get('/order-items/{id}', [OrderItemsController::class, 'show']);

    // payments
    Route::post('/payments', [PaymentsController::class, 'store']);
    Route::get('/payments', [PaymentsController::class, 'index']); // filter by user_id

    // customers (hanya update profil sendiri)
    Route::put('/customers/{id}', [CustomersController::class, 'update']);
    Route::get('/customers/{id}', [CustomersController::class, 'show']);
});