<?php

namespace App\Http\Controllers;

use App\Http\Resources\BaseResource;
use App\Models\Payments;
use App\Models\Products;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class PaymentsController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $payments = Payments::select(
            'payments.id',
            'payments.order_id',
            'payment_methods.metode as metode_pembayaran',
            'payments.jumlah_bayar',
            'payments.tanggal_bayar',
            'payments.status',
        )
            ->join('payment_methods', 'payment_methods.id', '=', 'payments.payment_method_id')
            ->get();

        return new BaseResource(true, 'List Data payments', $payments);
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
            'order_id' => 'required',
            'payment_method_id' => 'required',
            'jumlah_bayar' => 'required',
            'tanggal_bayar' => 'required',
            'status' => 'required',
        ]);
        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }
        $payments = Payments::create([
            'order_id' => $request->order_id,
            'payment_method_id' => $request->payment_method_id,
            'jumlah_bayar' => $request->jumlah_bayar,
            'tanggal_bayar' => $request->tanggal_bayar,
            'status' => $request->status,
        ]);

        return new BaseResource(true, 'Berhasil Menambahkan Data Payments', $payments);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $payments = Payments::select(
            'payments.id',
            'payments.order_id',
            'payment_methods.metode as metode_pembayaran',
            'payments.jumlah_bayar',
            'payments.tanggal_bayar',
            'payments.status',
        )
            ->join('payment_methods', 'payment_methods.id', '=', 'payments.payment_method_id')
            ->get();

        return new BaseResource(true, 'List Data payments', $payments);
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
            'order_id' => 'required',
            'payment_method_id' => 'required',
            'jumlah_bayar' => 'required',
            'tanggal_bayar' => 'required',
            'status' => 'required',
        ]);
        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $payments = Payments::findOrFail($id);

        if (!$payments) {
            return new BaseResource(false, 'Produk tidak ditemukan', null);
        }

        $payments->update([
            'order_id' => $request->order_id,
            'payment_method_id' => $request->payment_method_id,
            'jumlah_bayar' => $request->jumlah_bayar,
            'tanggal_bayar' => $request->tanggal_bayar,
            'status' => $request->status,
        ]);
        return new BaseResource(true, 'Data Berhasil diubah', $payments);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $payments = Payments::find($id);
        $payments->delete();

        return new BaseResource(true, 'Data Payments Berhasil dihapus', $payments);
    }
}
