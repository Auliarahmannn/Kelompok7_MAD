<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\OrderItems;
use App\Http\Resources\BaseResource;
use App\Models\Customers;
use Illuminate\Support\Facades\Auth;
use App\Models\Orders;
use Illuminate\Support\Facades\Validator;

class OrderItemsController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $user = Auth::user();
        $query = OrderItems::select(
            'order_items.id',
            'order_items.order_id',
            'order_items.product_id',
            'products.nama_produk',
            'order_items.jumlah_produk',
            'order_items.harga',
            'products.foto',     
            'orders.status'
        )
        ->join('products', 'products.id', '=', 'order_items.product_id')
        ->join('orders', 'orders.id', '=', 'order_items.order_id');

        if ($user->role === 'admin') {
            $items = $query->get();
        } else if ($user->role === 'customer') {
            $customersId = Customers::where('customers.user_id', $user->id)->value('id');

            if (!$customersId) {
                return new BaseResource(false, 'Data customer tidak ditemukan', null, 404);
            }
            
            // hanya order_items yang ada di order miliknya
            $items = $query
                ->where('orders.customer_id', $customersId)
                ->get();
                
            if ($items->isEmpty()) {
                return new BaseResource(false, 'Data tidak ditemukan', null, 404);
            }
        } else {
            return new BaseResource(false, 'Role tidak dikenali atau tidak diizinkan', null, 403);
        }

        return new BaseResource(true, 'List Data Order Items', $items, 200);
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
        $validator = Validator::make($request->all(), [
            'order_id' => 'required|integer',
            'product_id' => 'required|integer',
            'jumlah_produk' => 'required|integer',
            'harga' => 'required|numeric',
        ]);
        if ($validator->fails()) {
            return new BaseResource(false, 'Validasi gagal', $validator->errors(), 422);
        }

        $item = OrderItems::create([
            'order_id' => $request->order_id,
            'product_id' => $request->product_id,
            'jumlah_produk' => $request->jumlah_produk,
            'harga' => $request->harga,
        ]);

        return new BaseResource(true, 'Berhasil Menambahkan Data Order Items', $item, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $item = OrderItems::find($id);

        if (!$item) {
            return new BaseResource(false, 'Data Order Item Tidak Ditemukan', null, 404);
        }

        $items = OrderItems::select(
            'order_items.order_id',
            'products.nama_produk',
            'order_items.jumlah_produk',
            'order_items.harga'
        )
            ->join('products', 'products.id', '=', 'order_items.product_id')
            ->where('order_items.id', '=', $id)
            ->get();

        return new BaseResource(true, 'List Data Order Items', $items, 200);
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
        $validator = Validator::make($request->all(), [
            'order_id' => 'required|integer|exists:orders,id',
            'product_id' => 'required|integer|exists:products,id',
            'jumlah_produk' => 'required|integer',
            'harga' => 'required|numeric',
        ]);
        if ($validator->fails()) {
            return new BaseResource(false, 'Validasi gagal', $validator->errors(), 422);
        }

        $item = OrderItems::find($id);

        if (!$item) {
            return new BaseResource(false, 'Data Order Item Tidak Ditemukan', null, 404);
        }

        $item->update([
            'order_id' => $request->order_id,
            'product_id' => $request->product_id,
            'jumlah_produk' => $request->jumlah_produk,
            'harga' => $request->harga,
        ]);

        return new BaseResource(true, 'Data Berhasil diubah', $item, 200);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $item = OrderItems::find($id);

        if (!$item) {
            return response()->json([
                'success' => false,
                'message' => 'Data Order Item Tidak Ditemukan',
            ], 404);
        }

        $item->delete();

        return new BaseResource(true, 'Data Order Item Berhasil dihapus', $item, 200);
    }
}
