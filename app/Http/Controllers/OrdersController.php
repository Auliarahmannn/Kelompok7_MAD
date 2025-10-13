<?php

namespace App\Http\Controllers;

use App\Http\Resources\BaseResource;
use Illuminate\Http\Request;
use App\Models\Orders;
use Illuminate\Support\Facades\Validator;

class OrdersController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $orders = Orders::select(
            'customers.name as nama_customer',
            'orders.tanggal_pesan',
            'orders.total',
            'orders.status',
        )
            ->join('customers', 'customers.id', '=', 'orders.customer_id')
            ->get();

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
        $validator = Validator::make($request->all(), [
            'customer_id' => 'required|numeric|min:0|exists:customers,id',
            'tanggal_pesan' => 'required|date',
            'total' => 'required|numeric|min:0',
            'status' => 'required|in:pending,dikirim,dibayar,selesai,batal',
        ]);
        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }
        $orders = Orders::create([
            'customer_id' => $request->customer_id,
            'tanggal_pesan' => $request->tanggal_pesan,
            'total' => $request->total,
            'status' => $request->status,
        ]);

        return new BaseResource(true, 'Berhasil Menambahkan Data Orders', $orders);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $orders = Orders::select(
            'customers.name as nama_customer',
            'orders.tanggal_pesan',
            'orders.total',
            'orders.status',
        )
            ->join('customers', 'customers.id', '=', 'orders.customer_id')
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
        $validator = Validator::make($request->all(), [
            'customer_id' => 'required|numeric|min:0|exists:customers,id',
            'tanggal_pesan' => 'required|date',
            'total' => 'required|numeric|min:0',
            'status' => 'required|in:pending,dikirim,dibayar,selesai,batal',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $orders = Orders::findOrFail($id);

        if (!$orders) {
            return new BaseResource(false, 'Data tidak ditemukan', null);
        }

        $orders->update([
            'customer_id' => $request->customer_id,
            'tanggal_pesan' => $request->tanggal_pesan,
            'total' => $request->total,
            'status' => $request->status,
        ]);

        return new BaseResource(true, 'Berhasil Menambahkan Data Orders', $orders);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $orders = Orders::find($id);
        $orders->orderItems()->delete();
        $orders->payment()->delete();
        $orders->delete();

        return new BaseResource(true, 'Data Orders Berhasil dihapus', $orders);
    }
}
