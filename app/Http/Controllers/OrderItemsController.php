<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\OrderItems;
use App\Http\Resources\BaseResource;
use App\Models\Orders;



class OrderItemsController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
<<<<<<< HEAD
        //
        // $items = OrderItems::join('products', 'products.id', '=', 'order_items.product_id')
        //     ->select('order_items.*', 'products.name as nama_produk')
        //     ->get();
        // return new BaseResource(true, 'List Data Order Items', $items);
        $orders = Orders::all();
        $items = OrderItems::select('id', 'order_id', 'product_id', 'jumlah', 'harga')->get();
        return new BaseResource(true, 'List Data Orders', $orders);
=======
        $items = OrderItems::select(
            'order_items.order_id',
            'products.nama_produk',
            'order_items.jumlah',
            'order_items.harga',
        )
        ->join('products', 'products.id', '=', 'order_items.product_id')
        ->get();

        return new BaseResource(true, 'List Data Order Items', $items);
>>>>>>> main
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
        $request->validate([
            'order_id' => 'required|integer',
            'product_id' => 'required|integer',
            'jumlah' => 'required|integer',
            'harga' => 'required|numeric',
        ]);

        // 
        $item = OrderItems::create([
            'order_id' => $request->order_id,
            'product_id' => $request->product_id,
            'jumlah' => $request->jumlah,
            'harga' => $request->harga,
        ]);

        // 
        return response()->json([
            'success' => true,
            'message' => 'Data Order Item Berhasil Ditambahkan',
            'data' => $item
        ], 201);
    }


    /**
     * Display the specified resource.
     */
    public function show(string $id)
<<<<<<< HEAD
{
    //
    $item = OrderItems::find($id);

    if (!$item) {
        return response()->json([
            'success' => false,
            'message' => 'Data Order Item Tidak Ditemukan',
        ], 404);
=======
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
>>>>>>> main
    }

    return response()->json([
        'success' => true,
        'message' => 'Detail Data Order Item',
        'data' => $item
    ], 200);
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
         $item = OrderItems::find($id);

        if (!$item) {
            return response()->json([
                'success' => false,
                'message' => 'Data Order Item Tidak Ditemukan',
            ], 404);
        }

        $request->validate([
            'order_id' => 'required|integer',
            'product_id' => 'required|integer',
            'jumlah' => 'required|integer',
            'harga' => 'required|numeric',
        ]);

        $item->update([
            'order_id' => $request->order_id,
            'product_id' => $request->product_id,
            'jumlah' => $request->jumlah,
            'harga' => $request->harga,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Data Order Item Berhasil Diupdate',
            'data' => $item
        ], 200);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
         $item = OrderItems::find($id);

        if (!$item) {
            return response()->json([
                'success' => false,
                'message' => 'Data Order Item Tidak Ditemukan',
            ], 404);
        }

        $item->delete();

        return response()->json([
            'success' => true,
            'message' => 'Data Order Item Berhasil Dihapus'
        ], 200);
    
    }
}
