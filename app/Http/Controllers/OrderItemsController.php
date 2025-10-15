<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\OrderItems;
use App\Http\Resources\BaseResource;
use Illuminate\Support\Facades\Auth;

class OrderItemsController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $user = Auth::user();

        if ($user->role === 'admin') {
            $items = OrderItems::select(
                'order_items.order_id',
                'products.nama_produk',
                'order_items.jumlah',
                'order_items.harga'
            )
                ->join('products', 'products.id', '=', 'order_items.product_id')
                ->get();
        } else if ($user->role === 'customer') {
            // hanya order_items yang ada di order miliknya
            $items = OrderItems::select(
                'order_items.order_id',
                'products.nama_produk',
                'order_items.jumlah',
                'order_items.harga'
            )
                ->join('products', 'products.id', '=', 'order_items.product_id')
                ->join('orders', 'orders.id', '=', 'order_items.order_id')
                ->where('orders.customer_id', $user->id)
                ->get();
        } else {
            return response()->json([
                'success' => false,
                'message' => 'Role tidak dikenali atau tidak diizinkan',
                'data' => null
            ], 403);
        }

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
        $items = OrderItems::select(
            'order_items.order_id',
            'products.nama_produk',
            'order_items.jumlah',
            'order_items.harga',
        )
            ->join('products', 'products.id', '=', 'order_items.product_id')
            ->where('order_items.id', '=', $id)
            ->get();

        return new BaseResource(true, 'List Data Order Items', $items);
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
