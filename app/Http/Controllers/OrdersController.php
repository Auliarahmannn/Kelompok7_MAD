<?php

namespace App\Http\Controllers;

use App\Http\Resources\BaseResource;
use Illuminate\Http\Request;
use App\Models\Orders;

class OrdersController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        //
        // $orders = Orders::join('customers', 'customers.id', '=', 'orders.customer_id')
        //     ->select('orders.*', 'customers.name as nama-customer')
        //     ->get();
        // return new BaseResource(true, 'List Data Orders', $orders);
        $orders = Orders::all();
        return new BaseResource(true, 'List Data Orders', $orders);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id) 
    {
        //
        $orders = Orders::select('orders.*')
        ->where('orders.id', '=', $id)
        ->get();
        
        return new BaseResource(true, 'Detail data orders', $orders);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
    }
}
