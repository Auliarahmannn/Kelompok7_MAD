<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\CustomersController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\OrderItemsController;
use App\Http\Controllers\OrdersController;
use App\Http\Controllers\PaymentMethodController;
use App\Http\Controllers\PaymentsController;
use App\Http\Controllers\ProductController;

// ==================== AUTH ROUTES ====================
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// ==================== ADMIN ROUTES ====================
Route::middleware(['auth:sanctum', 'peran:admin'])->group(function () {

    // Products (edit & hapus)
    Route::post('/products', [ProductController::class, 'store']);
    Route::put('/products/{id}', [ProductController::class, 'update']);
    Route::delete('/products/{id}', [ProductController::class, 'destroy']);

    // Orders
    Route::delete('/orders/{id}', [OrdersController::class, 'destroy']);

    // Order Items
    Route::post('/order-items', [OrderItemsController::class, 'store']);
    Route::put('/order-items/{id}', [OrderItemsController::class, 'update']);
    Route::delete('/order-items/{id}', [OrderItemsController::class, 'destroy']);

    // Payments
    Route::put('/payments/{id}', [PaymentsController::class, 'update']);
    Route::delete('/payments/{id}', [PaymentsController::class, 'destroy']);

    // Payment Methods
    Route::post('/payment_method', [PaymentMethodController::class, 'store']);
    Route::put('/payment_method/{id}', [PaymentMethodController::class, 'update']);
    Route::delete('/payment_method/{id}', [PaymentMethodController::class, 'destroy']);

    // Customers
    Route::delete('/customers/{id}', [CustomersController::class, 'destroy']);
});

// ==================== CUSTOMER ROUTES ====================
Route::middleware(['auth:sanctum', 'peran:customer'])->group(function () {

    // Orders
    Route::post('/orders', [OrdersController::class, 'store']);

    // Order Items
    Route::post('/order-items', [OrderItemsController::class, 'store']);

    // Payments
    Route::post('/payments', [PaymentsController::class, 'store']);

    // Customers (update profil sendiri)
    Route::put('/customers/{id}', [CustomersController::class, 'update']);
});

// ==================== ROUTES ADMIN & CUSTOMER (GET SAJA) ====================
Route::middleware(['auth:sanctum', 'peran:admin-customer'])->group(function () {

    // Products (lihat semua)
    Route::get('/products', [ProductController::class, 'index']);
    Route::get('/products/{id}', [ProductController::class, 'show']);

    // Orders (admin: semua, customer: miliknya)
    Route::get('/orders', [OrdersController::class, 'index']);
    Route::get('/orders/{id}', [OrdersController::class, 'show']);

    // Order Items
    Route::get('/order-items', [OrderItemsController::class, 'index']);
    Route::get('/order-items/{id}', [OrderItemsController::class, 'show']);

    // Payments
    Route::get('/payments', [PaymentsController::class, 'index']);
    Route::get('/payments/{id}', [PaymentsController::class, 'show']);

    // Payment Methods
    Route::get('/payment_method', [PaymentMethodController::class, 'index']);

    // Customers
    Route::get('/customers', [CustomersController::class, 'index']);
    Route::get('/customers/{id}', [CustomersController::class, 'show']);
});
