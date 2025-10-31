<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Models\Orders;
use App\Models\OrderItems;
use App\Models\Products;
use App\Models\Customers;
use App\Models\Payments;
use App\Models\PaymentMethod; // Pastikan nama model Anda 'PaymentMethod'
use App\Http\Resources\BaseResource;

class CheckoutController extends Controller
{
    /**
     * Hitung ulang total harga order 'pending' (keranjang).
     */
    private function recalculateOrderTotal($orderId)
    {
        $order = Orders::find($orderId);
        if ($order) {
            // Hitung total hanya dari item yang TERSISA di keranjang
            $total = $order->orderItems()->sum(DB::raw('harga * jumlah_produk'));
            $order->total_harga = $total;
            $order->save();
            return $total;
        }
        return 0;
    }

    /**
     * Proses checkout
     */
    public function processCheckout(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'payment_method_id' => 'required|integer|exists:payment_methods,id',
            'items' => 'required|array',
            'items.*.product_id' => 'required|integer|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.order_item_id' => 'required|integer', // ID dari keranjang
        ]);

        if ($validator->fails()) {
            return new BaseResource(false, 'Validasi gagal', $validator->errors(), 422);
        }

        /** @var \App\Models\User $user */
        $user = Auth::user();
        $customer = Customers::where('user_id', $user->id)->first();

        // Ambil ID item keranjang yang asli
        $cartItemIds = array_column($request->items, 'order_item_id');
        
        // Verifikasi bahwa semua item milik user
        $pendingOrder = Orders::where('customer_id', $customer->id)
                                ->where('status', 'pending')
                                ->first();

        if (!$pendingOrder) {
             return new BaseResource(false, 'Keranjang tidak ditemukan', null, 404);
        }

        // Cek apakah item yang di-checkout ada di keranjang
        $itemsFromDb = OrderItems::where('order_id', $pendingOrder->id)
                                 ->whereIn('id', $cartItemIds)
                                 ->get();

        // Pastikan jumlah item yang dikirim dari frontend SAMA dengan
        // yang ditemukan di keranjang user
        if (count($itemsFromDb) != count($cartItemIds)) {
             return new BaseResource(false, 'Beberapa item tidak valid atau tidak ada di keranjang', null, 400);
        }

        // Mulai transaksi Database
        DB::beginTransaction();
        try {
            $totalHarga = 0;

            // 1. Cek Stok dan hitung total harga
            foreach ($itemsFromDb as $item) {
                // Kunci produk untuk menghindari race condition
                $product = Products::where('id', $item->product_id)->lockForUpdate()->first();
                
                if ($item->jumlah_produk > $product->stok) {
                    DB::rollBack();
                    return new BaseResource(false, 'Stok untuk ' . $product->nama_produk . ' tidak mencukupi (sisa ' . $product->stok . ')', null, 400);
                }
                $totalHarga += ($item->harga * $item->jumlah_produk);
            }

            // 2. Buat Order baru dengan status 'dibayar' (atau 'menunggu pembayaran')
            $newOrder = Orders::create([
                'customer_id' => $customer->id,
                'tanggal_pesan' => now(),
                'total_harga' => $totalHarga,
                'status' => 'dibayar' // Ganti jadi 'menunggu' jika perlu konfirmasi
            ]);

            // 3. Pindahkan OrderItems dari order 'pending' ke order baru
            foreach ($itemsFromDb as $item) {
                // Pindahkan
                $item->order_id = $newOrder->id;
                $item->save();

                // 4. Kurangi Stok Produk
                $product = Products::find($item->product_id); // Ambil lagi (sudah di-lock)
                $product->stok -= $item->jumlah_produk;
                $product->save();
            }

            // 5. Buat catatan Pembayaran (Payment)
            Payments::create([
                'order_id' => $newOrder->id,
                'payment_method_id' => $request->payment_method_id,
                'jumlah_bayar' => $totalHarga,
                'tanggal_bayar' => now(),
                'status' => 'berhasil' // Ganti 'menunggu' jika perlu konfirmasi
            ]);

            // 6. Hitung ulang total keranjang (pending order) yang lama
            // Ini akan mengosongkan harga di keranjang
            $this->recalculateOrderTotal($pendingOrder->id);

            // Jika semua berhasil
            DB::commit();

            return new BaseResource(true, 'Checkout berhasil', ['order_id' => $newOrder->id], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return new BaseResource(false, 'Checkout gagal: ' . $e->getMessage(), null, 500);
        }
    }
}