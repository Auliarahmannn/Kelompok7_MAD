<?php

namespace App\Http\Controllers;

use App\Http\Resources\BaseResource;
use App\Models\Products;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ProductController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $products = Products::select(
            'products.id',
            'products.nama_produk',
            'products.deskripsi',
            'products.harga',
            'products.stok',
            'products.foto',
        )->get();

        return new BaseResource(true, 'List Data products', $products);
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
            'nama_produk' => 'required',
            'deskripsi' => 'required',
            'harga' => 'required|numeric|min:0',
            'stok' => 'required|numeric',
            'foto' => 'required',
        ]);
        if($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }
        $products = Products::create([
            'nama_produk' => $request->nama_produk,
            'deskripsi' => $request->deskripsi,
            'harga' => $request->harga,
            'stok' => $request->stok,
            'foto' => $request->foto,
        ]);

        return new BaseResource(true, 'Berhasil Menambahkan Data Products', $products);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $products = Products::select(
            'products.id',
            'products.nama_produk',
            'products.deskripsi',
            'products.harga',
            'products.stok',
            'products.foto',
        )
            ->where('products.id', '=', $id)
            ->get();

        return new BaseResource(true, 'List Data products', $products);
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
            'nama_produk' => 'required',
            'deskripsi' => 'required',
            'harga' => 'required|numeric|min:0',
            'stok' => 'required|numeric',
            'foto' => 'required',
        ]);

        if($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $products = Products::findOrFail($id);

        if (!$products) {
            return new BaseResource(false, 'Produk tidak ditemukan', null);
        }

        $products->update([
            'nama_produk' => $request->nama_produk,
            'deskripsi' => $request->deskripsi,
            'harga' => $request->harga,
            'stok' => $request->stok,
            'foto' => $request->foto,
        ]);
        return new BaseResource(true, 'Data Berhasil diubah', $products);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $products = Products::find($id);
        $products->orderItems()->delete();
        $products->delete();

        return new BaseResource(true, 'Data Products Berhasil dihapus', $products);
    }
}
