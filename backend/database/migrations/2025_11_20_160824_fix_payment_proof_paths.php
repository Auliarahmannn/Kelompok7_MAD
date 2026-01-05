<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up()
    {
        // Hapus prefix 'storage/' dari path
        DB::table('payments')
            ->whereNotNull('proof_of_payment')
            ->where('proof_of_payment', 'like', 'storage/%')
            ->update([
                'proof_of_payment' => DB::raw("REPLACE(proof_of_payment, 'storage/', '')")
            ]);
        
        // Log hasil
        $fixed = DB::table('payments')
            ->whereNotNull('proof_of_payment')
            ->where('proof_of_payment', 'like', 'payment_proofs/%')
            ->count();
            
        \Log::info("Fixed $fixed payment proof paths");
    }

    public function down()
    {
        // Kembalikan prefix jika rollback
        DB::table('payments')
            ->whereNotNull('proof_of_payment')
            ->where('proof_of_payment', 'like', 'payment_proofs/%')
            ->update([
                'proof_of_payment' => DB::raw("CONCAT('storage/', proof_of_payment)")
            ]);
    }
};