<?php

namespace App\Http\Controllers;

use App\Http\Resources\BaseResource;
use App\Models\Customers;
use Illuminate\Http\Request;
use App\Models\Orders;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;

class OrdersController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $user = Auth::user();
        $query = Orders::select(
                'customers.name as nama_customer',
                'orders.tanggal_pesan',
                'orders.total_harga',
                'orders.status'
            )->join('customers', 'customers.id', '=', 'orders.customer_id');

        if ($user->role === 'admin') {
            $orders = $query->get();
        } else if ($user->role === 'customer') {
            $customersId = Customers::where('customers.user_id', $user->id)->value('id');
            
            // hanya lihat order miliknya sendiri
            $orders = $query
                ->join('customers', 'customers.id', '=', 'orders.customer_id')
                ->where('orders.customer_id', $customersId)->get();
                
            if ($orders->isEmpty()) {
                return new BaseResource(false, 'Data tidak ditemukan', null, 404);
            }
            
        } else {
            return new BaseResource(false, 'Role tidak dikenali atau tidak diizinkan', null, 403);
        }

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
            'total_harga' => 'required|numeric|min:0',
            'status' => 'required|in:pending,dikirim,dibayar,selesai,batal',
        ]);
        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }
        $orders = Orders::create([
            'customer_id' => $request->customer_id,
            'tanggal_pesan' => $request->tanggal_pesan,
            'total_harga' => $request->total_harga,
            'status' => $request->status,
        ]);

        return new BaseResource(true, 'Berhasil Menambahkan Data Orders', $orders, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $orders = Orders::find($id);

        if (!$orders) {
            return new BaseResource(false, 'Data Order tidak ditemukan', null, 404);
        }

        $orders = Orders::select(
            'customers.name as nama_customer',
            'orders.tanggal_pesan',
            'orders.total_harga',
            'orders.status',
        )
            ->join('customers', 'customers.id', '=', 'orders.customer_id')
            ->where('orders.id', '=', $id)
            ->get();

        return new BaseResource(true, 'Detail data orders', $orders, 200);
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
            'total_harga' => 'required|numeric|min:0',
            'status' => 'required|in:pending,dikirim,dibayar,selesai,batal',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $orders = Orders::find($id);

        if (!$orders) {
            return new BaseResource(false, 'Data tidak ditemukan', null, 404);
        }

        $orders->update([
            'customer_id' => $request->customer_id,
            'tanggal_pesan' => $request->tanggal_pesan,
            'total_harga' => $request->total_harga,
            'status' => $request->status,
        ]);

        return new BaseResource(true, 'Berhasil Menambahkan Data Orders', $orders, 200);
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

        return new BaseResource(true, 'Data Orders Berhasil dihapus', $orders, 200);
    }
}
