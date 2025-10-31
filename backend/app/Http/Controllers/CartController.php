<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Orders;
use App\Models\OrderItems;
use App\Models\Products;
use App\Models\Customers;
use App\Http\Resources\BaseResource;
use Illuminate\Support\Facades\Validator;

class CartController extends Controller
{
    /**
     * Dapatkan atau buat order 'pending' untuk user.
     * Ini adalah fungsi helper untuk controller ini.
     */
    private function getOrCreatePendingOrder($customerId)
    {
        return Orders::firstOrCreate(
            [
                'customer_id' => $customerId,
                'status' => 'pending'
            ],
            [
                'tanggal_pesan' => now(),
                'total_harga' => 0
            ]
        );
    }

    /**
     * Hitung ulang total harga order berdasarkan item-itemnya.
     */
    private function recalculateOrderTotal($orderId)
    {
        $order = Orders::find($orderId);
        if ($order) {
            $total = $order->orderItems()->sum(\DB::raw('harga * jumlah_produk'));
            $order->total_harga = $total;
            $order->save();
            return $total;
        }
        return 0;
    }

    /**
     * Ambil item keranjang (pending order) milik user.
     */
    public function getCart()
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();
        $customer = Customers::where('user_id', $user->id)->first();

        if (!$customer) {
            return new BaseResource(false, 'Customer tidak ditemukan', [], 404);
        }

        // Cari order yang masih pending (ini adalah keranjangnya)
        $pendingOrder = Orders::where('customer_id', $customer->id)
            ->where('status', 'pending')
            ->first();

        if (!$pendingOrder) {
            // Jika tidak ada, berarti keranjang kosong
            return new BaseResource(true, 'Keranjang kosong', [], 200);
        }

        // Ambil semua item di order itu, join dengan produk
        $cartItems = OrderItems::where('order_id', $pendingOrder->id)
            ->join('products', 'order_items.product_id', '=', 'products.id')
            ->select(
                'order_items.id as order_item_id',
                'order_items.order_id',
                'order_items.jumlah_produk',
                'order_items.harga', // Harga saat ditambahkan
                'products.id as product_id',
                'products.nama_produk',
                'products.foto as product_image',
                'products.stok as product_stock'
            )
            ->get();

        return new BaseResource(true, 'Data keranjang berhasil diambil', $cartItems, 200);
    }

    /**
     * Tambah item ke keranjang.
     */
    public function addToCart(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'product_id' => 'required|integer|exists:products,id',
            'quantity' => 'required|integer|min:1',
        ]);

        if ($validator->fails()) {
            return new BaseResource(false, 'Validasi gagal', $validator->errors(), 422);
        }

        /** @var \App\Models\User $user */
        $user = Auth::user();
        $customer = Customers::where('user_id', $user->id)->first();
        $product = Products::find($request->product_id);

        if ($request->quantity > $product->stok) {
             return new BaseResource(false, 'Stok tidak mencukupi', null, 400);
        }

        // 1. Dapatkan atau buat 'pending order'
        $order = $this->getOrCreatePendingOrder($customer->id);

        // 2. Cek apakah item sudah ada di keranjang
        $item = OrderItems::where('order_id', $order->id)
            ->where('product_id', $product->id)
            ->first();

        if ($item) {
            // Jika ada, update jumlahnya
            $item->jumlah_produk += $request->quantity;
            // Pastikan tidak melebihi stok
            if ($item->jumlah_produk > $product->stok) {
                $item->jumlah_produk = $product->stok;
            }
            $item->save();
        } else {
            // Jika tidak ada, buat baru
            $item = OrderItems::create([
                'order_id' => $order->id,
                'product_id' => $product->id,
                'jumlah_produk' => $request->quantity,
                'harga' => $product->harga, // Ambil harga dari produk saat ini
            ]);
        }

        // 3. Hitung ulang total
        $this->recalculateOrderTotal($order->id);

        return new BaseResource(true, 'Item berhasil ditambahkan ke keranjang', $item, 201);
    }

    /**
     * Update jumlah item di keranjang.
     */
    public function updateCartItem(Request $request, $orderItemId)
    {
        $validator = Validator::make($request->all(), [
            'quantity' => 'required|integer|min:1',
        ]);

        if ($validator->fails()) {
            return new BaseResource(false, 'Validasi gagal', $validator->errors(), 422);
        }

        $item = OrderItems::find($orderItemId);
        if (!$item) {
            return new BaseResource(false, 'Item tidak ditemukan', null, 404);
        }

        // Verifikasi kepemilikan (opsional tapi aman)
        // ... (bisa ditambahkan cek apakah order_id di item ini milik user yg login) ...

        $product = Products::find($item->product_id);
        if ($request->quantity > $product->stok) {
             return new BaseResource(false, 'Stok tidak mencukupi', null, 400);
        }

        $item->jumlah_produk = $request->quantity;
        $item->save();

        // Hitung ulang total
        $this->recalculateOrderTotal($item->order_id);

        return new BaseResource(true, 'Jumlah item diperbarui', $item, 200);
    }

    /**
     * Hapus item dari keranjang.
     */
    public function removeCartItem($orderItemId)
    {
        $item = OrderItems::find($orderItemId);
        if (!$item) {
            return new BaseResource(false, 'Item tidak ditemukan', null, 404);
        }

        // Verifikasi kepemilikan
        // ...

        $orderId = $item->order_id;
        $item->delete();

        // Hitung ulang total
        $this->recalculateOrderTotal($orderId);

        return new BaseResource(true, 'Item dihapus dari keranjang', null, 200);
    }
}