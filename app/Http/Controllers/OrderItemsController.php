<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\OrderItems; 
use App\Http\Resources\BaseResource; 


class OrderItemsController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        //
        $items = OrderItems::join('products', 'products.id', '=', 'order_items.product_id')
            ->select('order_items.*', 'products.name as nama_produk')
            ->get();

        return new BaseResource(true, 'List Data Order Items', $items);
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
        $item = OrderItems::create($request->all());
        return new BaseResource(true, 'Data Order Item Berhasil Ditambahkan', $item);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        //
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
