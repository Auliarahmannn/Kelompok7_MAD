<?php

namespace App\Http\Controllers;

use App\Http\Resources\BaseResource;
use App\Models\Payments;
use Illuminate\Http\Request;

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
        //
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
