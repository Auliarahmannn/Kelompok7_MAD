<?php

use App\Http\Controllers\CustomersController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\OrdersController;
use App\Http\Controllers\OrderItemsController;
use App\Http\Controllers\PaymentMethodController;
use App\Http\Controllers\PaymentsController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\AuthController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// orders
// Route::get('/orders', [OrdersController::class, 'index']);
Route::get('/orders/{id}', [OrdersController::class, 'show']);
Route::post('/orders', [OrdersController::class, 'store']);
Route::put('/orders/{id}', [OrdersController::class, 'update']);
Route::delete('/orders/{id}', [OrdersController::class, 'destroy']);

// order items
Route::get('/order-items', [OrderItemsController::class, 'index']);
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
Route::get('/payments/{id}', [PaymentsController::class, 'show']);
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
