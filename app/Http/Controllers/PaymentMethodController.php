<?php

namespace App\Http\Controllers;

use App\Http\Resources\BaseResource;
use App\Models\PaymentMethod;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class PaymentMethodController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $paymentmethod = PaymentMethod::all();

        return new BaseResource(true, 'List Data Paymen Method', $paymentmethod, 200);
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
         $validator = Validator::make($request->all(), [
            'metode' => 'required',
            'deskripsi' => 'required',
        ]);
        if($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }
        $paymentmethod = PaymentMethod::create([
            'metode' => $request->metode,
            'deskripsi' => $request->deskripsi,
        ]);

        return new BaseResource(true, 'Berhasil Menambahkan Data Payment Method', $paymentmethod, 201);
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
         $validator = Validator::make($request->all(), [
            'metode' => 'required',
            'deskripsi' => 'required',
        ]);
        if($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $paymentmethod = PaymentMethod::find($id);

        if (!$paymentmethod) {
            return new BaseResource(false, 'Metode Tidak ditemukan', null, 404);
        }

        $paymentmethod->update([
            'metode' => $request->metode,
            'deskripsi' => $request->deskripsi,
        ]);
        return new BaseResource(true, 'Pembayaran Berhasil', $paymentmethod, 200);

    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
        $paymentmethod = PaymentMethod::find($id);

        if (!$paymentmethod) {
            return new BaseResource(false, 'Metode Tidak ditemukan', null, 404);
        }
        $paymentmethod->payments()->delete();
        $paymentmethod->delete();

        return new BaseResource(true, 'Data Payment Method Berhasil dihapus', $paymentmethod, 200);
    }
}
