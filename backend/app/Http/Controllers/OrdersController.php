<?php

namespace App\Http\Controllers;

use App\Http\Resources\BaseResource;
use App\Models\Customers;
use Illuminate\Http\Request;
use App\Models\Orders;
use App\Models\Products;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

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
            // Kita gunakan Eager Loading untuk mengambil relasi
            $orders = Orders::with([
                'customer:id,name', 
                'orderItems', 
                'orderItems.product:id,nama_produk' 
            ])
            ->orderBy('tanggal_pesan', 'desc') 
            ->get();

            if ($orders->isEmpty()) {
                return new BaseResource(true, 'Belum ada data pesanan', null);
            }

            return new BaseResource(true, 'List Data Orders (Admin)', $orders);
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

    /**
     * Update status pesanan (khusus admin).
     */
    public function updateStatus(Request $request, $id)
    {
        // 1. Cek apakah user adalah admin
        if (Auth::user()->role !== 'admin') {
            return new BaseResource(false, 'Hanya admin yang dapat mengakses', null, 403);
        }

        // 2. Validasi input
        $validator = Validator::make($request->all(), [
            'status' => 'required|in:pending,dibayar,dikirim,selesai,batal',
            'validation_note' => 'nullable|string|max:255', // TAMBAH
        ]);
        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $order = Orders::find($id);
        // ... (check !$order)
        
        $payment = $order->payment;
        $newStatus = $request->status;
        $validationNote = $request->validation_note;
        
        // Cek bukti bayar jika status mau diubah ke 'dikirim' atau 'batal'
        if (($newStatus === 'dikirim' || $newStatus === 'batal') && (!$payment || !$payment->proof_of_payment)) {
             return new BaseResource(false, 'Bukti pembayaran harus diupload sebelum status diubah ke dikirim atau batal', null, 400);
        }
        
        // Update Order Status
        $order->status = $newStatus;
        $order->save();
        
        // Update Payments table jika ada catatan atau status dibatalkan
        if ($payment) {
            if ($newStatus === 'batal') {
                $payment->status = 'gagal'; // Tanda pembayaran gagal dikonfirmasi
            }
            $payment->validation_note = $validationNote;
            $payment->save();
        }

        return new BaseResource(true, 'Status order berhasil diupdate', $order, 200);
    }

    /**
     * Konfirmasi pesanan diterima (khusus customer).
     */
    public function receiveOrder(Request $request, string $id)
    {
        // 1. Dapatkan user & customer ID
        $user = Auth::user();
        if ($user->role !== 'customer') {
            return new BaseResource(false, 'Hanya customer yang dapat melakukan ini', null, 403);
        }

        $customersId = Customers::where('customers.user_id', $user->id)->value('id');
        if (!$customersId) {
            return new BaseResource(false, 'Data customer tidak ditemukan', null, 404);
        }

        // 2. Cari order
        $order = Orders::find($id);
        if (!$order) {
            return new BaseResource(false, 'Data order tidak ditemukan', null, 404);
        }

        // 3. Validasi Keamanan: Pastikan order ini milik user
        if ($order->customer_id !== $customersId) {
            return new BaseResource(false, 'Anda tidak memiliki akses ke order ini', null, 403);
        }

        // 4. Validasi Status: Pastikan status 'dikirim'
        if ($order->status !== 'dikirim') {
            return new BaseResource(false, 'Pesanan ini tidak dalam status "dikirim"', null, 422);
        }

        // 5. Update status
        $order->status = 'selesai';
        $order->save();

        return new BaseResource(true, 'Status order berhasil diupdate ke "Selesai"', $order, 200);
    }

    /**
     * Batalkan pesanan oleh customer (hanya status 'dibayar').
     */
    public function cancelOrder(string $id)
    {
        $user = Auth::user();
        if ($user->role !== 'customer') {
            return new BaseResource(false, 'Hanya customer yang dapat melakukan ini', null, 403);
        }

        $customersId = Customers::where('customers.user_id', $user->id)->value('id');
        $order = Orders::find($id);

        if (!$order || $order->customer_id !== $customersId) {
            return new BaseResource(false, 'Order tidak ditemukan atau akses ditolak', null, 404);
        }

        // Hanya boleh dibatalkan jika statusnya 'dibayar' (Menunggu Bayar)
        if ($order->status !== 'dibayar') {
            return new BaseResource(false, 'Pesanan hanya dapat dibatalkan saat status "Menunggu Bayar"', null, 400);
        }

        DB::beginTransaction();
        try {
            // 1. Update status order menjadi 'batal'
            $order->status = 'batal';
            $order->save();

            // 2. Kembalikan stok produk
            foreach ($order->orderItems as $item) {
                $product = Products::find($item->product_id);
                if ($product) {
                    $product->stok += $item->jumlah_produk;
                    $product->save();
                }
            }
            
            // 3. Update status pembayaran menjadi 'gagal' atau 'dibatalkan'
            $payment = $order->payment;
            if ($payment) {
                $payment->status = 'gagal'; 
                $payment->save();
            }

            DB::commit();
            return new BaseResource(true, 'Pesanan berhasil dibatalkan dan stok dikembalikan', null, 200);

        } catch (\Exception $e) {
            DB::rollBack();
            return new BaseResource(false, 'Pembatalan gagal: ' . $e->getMessage(), null, 500);
        }
    }

    /**
     * Dapatkan statistik pendapatan (khusus admin) dengan filter.
     */
    public function getStatistics(string $filter = 'harian')
    {
        try {
            // --- 1. MEMBUAT QUERY DASAR UNTUK FILTER WAKTU ---
            $baseQuery = Orders::query();
            switch ($filter) {
                case 'harian':
                    $baseQuery->whereDate('tanggal_pesan', now()->today());
                    break;
                case 'bulanan':
                    $baseQuery->whereMonth('tanggal_pesan', now()->month)
                              ->whereYear('tanggal_pesan', now()->year);
                    break;
                case 'tahunan':
                    $baseQuery->whereYear('tanggal_pesan', now()->year);
                    break;
            }

            // --- 2. PERHITUNGAN UNTUK KARTU STATISTIK (SAMA SEPERTI SEBELUMNYA) ---
            
            // Clone query dasar agar bisa dipakai beberapa kali
            $statsQuery = clone $baseQuery;
            $itemsQuery = clone $baseQuery;
            $pendingQuery = clone $baseQuery;

            $stats = $statsQuery->select(
                DB::raw("SUM(CASE WHEN status = 'selesai' THEN total_harga ELSE 0 END) as total_pendapatan_selesai"),
                DB::raw("COUNT(CASE WHEN status = 'selesai' THEN 1 END) as jumlah_pesanan_selesai"),
                DB::raw("COUNT(CASE WHEN status IN ('dibayar', 'dikirim') THEN 1 END) as jumlah_pesanan_diproses"),
                DB::raw("COUNT(CASE WHEN status = 'batal' THEN 1 END) as jumlah_pesanan_batal")
            )->first();

            $totalBarang = $itemsQuery->where('status', 'selesai')
                                     ->join('order_items', 'orders.id', '=', 'order_items.order_id')
                                     ->sum('order_items.jumlah_produk');

            $pendingRevenue = $pendingQuery->whereIn('status', ['dibayar', 'dikirim'])->sum('total_harga');

            
            // --- 3. PERHITUNGAN BARU UNTUK DATA GRAFIK ---

            $chartQuery = clone $baseQuery; // Ambil query dasar lagi
            $chartQuery->where('status', 'selesai'); // Grafik HANYA menghitung pendapatan 'selesai'
            
            // Tentukan cara mengelompokkan data (per jam, hari, atau bulan)
            switch ($filter) {
                case 'harian':
                    $chartQuery->select(
                        DB::raw("HOUR(tanggal_pesan) as label"), 
                        DB::raw("SUM(total_harga) as total")
                    )->groupBy('label')->orderBy('label', 'asc');
                    break;
                case 'bulanan':
                    $chartQuery->select(
                        DB::raw("DAY(tanggal_pesan) as label"),
                        DB::raw("SUM(total_harga) as total")
                    )->groupBy('label')->orderBy('label', 'asc');
                    break;
                case 'tahunan':
                    $chartQuery->select(
                        DB::raw("MONTH(tanggal_pesan) as label"),
                        DB::raw("SUM(total_harga) as total")
                    )->groupBy('label')->orderBy('label', 'asc');
                    break;
            }

            $chartData = $chartQuery->get(); // Ambil data grafiknya

            // --- 4. GABUNGKAN SEMUA DATA UNTUK DIKIRIM ---
            $data = [
                // Data untuk Kartu
                'pendapatan_selesai' => (float) $stats->total_pendapatan_selesai ?? 0,
                'pesanan_selesai' => (int) $stats->jumlah_pesanan_selesai ?? 0,
                'barang_terjual' => (int) $totalBarang ?? 0,
                'pesanan_diproses' => (int) $stats->jumlah_pesanan_diproses ?? 0,
                'pesanan_dibatalkan' => (int) $stats->jumlah_pesanan_batal ?? 0,
                'pendapatan_diproses' => (float) $pendingRevenue ?? 0,

                // Data BARU untuk Grafik
                'chart_data' => $chartData,
            ];

            return new BaseResource(true, 'Data statistik berhasil diambil', $data, 200);

        } catch (\Exception $e) {
            return new BaseResource(false, 'Gagal mengambil statistik: ' . $e->getMessage(), null, 500);
        }
    }
}
