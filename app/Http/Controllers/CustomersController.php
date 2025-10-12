<?php

namespace App\Http\Controllers;

use App\Http\Resources\BaseResource;
use App\Models\Customers;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CustomersController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $customers = Customers::select(
            'customers.id',
            'customers.name',
            'customers.email',
            'customers.phone',
            'customers.address'
        )->get();

        return new BaseResource(true, 'List Data Customers', $customers);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:100',
            'email' => 'required|email|unique:customers,email',
            'phone' => 'required|string|max:15',
            'address' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $customers = Customers::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'address' => $request->address,
        ]);

        return new BaseResource(true, 'Berhasil Menambahkan Data Customer', $customers);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $customers = Customers::select(
            'customers.id',
            'customers.name',
            'customers.email',
            'customers.phone',
            'customers.address'
        )
        ->where('customers.id', '=', $id)
        ->get();

        if ($customers->isEmpty()) {
            return new BaseResource(false, 'Data Customer Tidak Ditemukan', null);
        }

        return new BaseResource(true, 'Detail Data Customer', $customers);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:100',
            'email' => 'required|email|unique:customers,email,' . $id,
            'phone' => 'required|string|max:15',
            'address' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $customers = Customers::find($id);

        if (!$customers) {
            return new BaseResource(false, 'Data Customer Tidak Ditemukan', null);
        }

        $customers->update([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'address' => $request->address,
        ]);

        return new BaseResource(true, 'Data Customer Berhasil Diubah', $customers);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $customers = Customers::find($id);

        if (!$customers) {
            return new BaseResource(false, 'Data Customer Tidak Ditemukan', null);
        }

        // Jika memiliki relasi ke orders, hapus juga data terkait
        $customers->orders()->delete();

        $customers->delete();

        return new BaseResource(true, 'Data Customer Berhasil Dihapus', $customers);
    }
}
