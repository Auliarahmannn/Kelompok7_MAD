<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\CustomersController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\OrdersController;
use App\Http\Controllers\OrderItemsController;
use App\Http\Controllers\PaymentMethodController;
use App\Http\Controllers\PaymentsController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\AuthController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

<<<<<<< HEAD
// orders
// Route::get('/orders', [OrdersController::class, 'index']);
Route::get('/orders/{id}', [OrdersController::class, 'show']);
Route::post('/orders', [OrdersController::class, 'store']);
Route::put('/orders/{id}', [OrdersController::class, 'update']);
Route::delete('/orders/{id}', [OrdersController::class, 'destroy']);
=======
// ==================== ADMIN ROUTES ====================
Route::middleware(['auth:sanctum', 'peran:admin'])->group(function () {
    // Products
    Route::post('/products', [ProductController::class, 'store']);
    Route::put('/products/{id}', [ProductController::class, 'update']);
    Route::delete('/products/{id}', [ProductController::class, 'destroy']);
>>>>>>> main

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

<<<<<<< HEAD
// customers
Route::get('/customers', [CustomersController::class, 'index']);
Route::get('/customers/{id}', [CustomersController::class, 'show']);
Route::post('/customers', [CustomersController::class, 'store']);
Route::put('/customers/{id}', [CustomersController::class, 'update']);
Route::delete('/customers/{id}', [CustomersController::class, 'destroy']);

// auth
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// route protected
Route::middleware(['auth:sanctum', 'peran:admin-customer'])->group(function () {
    Route::get('/user', [AuthController::class, 'index']);

    // orders
    Route::get('/orders', [OrdersController::class, 'index']);
    Route::get('/orders/{id}', [OrdersController::class, 'show']);
    Route::post('/orders', [OrdersController::class, 'store']);
    Route::put('/orders/{id}', [OrdersController::class, 'update']);
    Route::delete('/orders/{id}', [OrdersController::class, 'destroy']);

    // order items
    Route::get('/order-items', [OrderItemsController::class, 'index']);
    Route::get('/my-orders', [OrdersController::class, 'index']);
    Route::get('/order-items/{id}', [OrderItemsController::class, 'show']);
    Route::post('/order-items', [OrderItemsController::class, 'store']);
    Route::put('/order-items/{id}', [OrderItemsController::class, 'update']);
    Route::delete('/order-items/{id}', [OrderItemsController::class, 'destroy']);

    // products
    Route::get('/products', [ProductController::class, 'index']);
    Route::get('/products/{id}', [ProductController::class, 'show']);
    Route::post('/products', [ProductController::class, 'store']);
    Route::put('/products/{id}', [ProductController::class, 'update']);
    Route::delete('/products/{id}', [ProductController::class, 'destroy']);

    // payments 
    Route::get('/payments', [PaymentsController::class, 'index']);
    Route::get('/payments/{id}', 
    
    [PaymentsController::class, 'show']);
    Route::post('/payments', [PaymentsController::class, 'store']);
    Route::put('/payments/{id}', [PaymentsController::class, 'update']);
    Route::delete('/payments/{id}', [PaymentsController::class, 'destroy']);

    // payment method
    Route::get('/payment_method', [PaymentMethodController::class, 'index']);
    Route::get('/payment_method/{id}', [PaymentMethodController::class, 'show']);
    Route::post('/payment_method', [PaymentMethodController::class, 'store']);
    Route::put('/payment_method/{id}', [PaymentMethodController::class, 'update']);
    Route::delete('/payment_method/{id}', [PaymentMethodController::class, 'destroy']);

    // customers
    Route::get('/customers', [CustomersController::class, 'index']);
    Route::get('/customers/{id}', [CustomersController::class, 'show']);
    Route::post('/customers', [CustomersController::class, 'store']);
    Route::put('/customers/{id}', [CustomersController::class, 'update']);
    Route::delete('/customers/{id}', [CustomersController::class, 'destroy']);
});
=======

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
>>>>>>> main
