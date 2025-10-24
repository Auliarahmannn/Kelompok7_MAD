<?php

namespace App\Http\Controllers;

use App\Http\Resources\BaseResource;
use App\Models\User;
use App\Models\Customers;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class UsersController extends Controller
{
    /**
     * Get authenticated user profile with customer data
     */
    public function getProfile()
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();

        if (!$user) {
            return new BaseResource(false, 'User tidak ditemukan', null, 404);
        }

        // Ambil data customer berdasarkan user_id
        $customer = Customers::where('user_id', $user->id)->first();

        $profileData = [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'phone' => $customer ? $customer->phone : null,
            'address' => $customer ? $customer->address : null,
            'customer_id' => $customer ? $customer->id : null,
            'created_at' => $user->created_at,
            'updated_at' => $user->updated_at,
        ];

        return new BaseResource(true, 'Data profil berhasil diambil', $profileData, 200);
    }

    /**
     * Update user profile
     */
    public function updateProfile(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();

        if (!$user) {
            return new BaseResource(false, 'User tidak ditemukan', null, 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'nullable|string|max:255',
            'email' => 'nullable|string|email|unique:users,email,' . $user->id,
            'phone' => 'nullable|string|max:15',
            'address' => 'nullable|string|max:255',
            'current_password' => 'nullable|string',
            'new_password' => 'nullable|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return new BaseResource(false, 'Validasi gagal', $validator->errors(), 422);
        }

        // Update password jika ada
        if ($request->filled('current_password') && $request->filled('new_password')) {
            if (!Hash::check($request->current_password, $user->password)) {
                return new BaseResource(false, 'Password lama tidak sesuai', null, 400);
            }
            $user->password = Hash::make($request->new_password);
        }

        // Update data user
        if ($request->filled('name')) {
            $user->name = $request->name;
        }
        if ($request->filled('email')) {
            $user->email = $request->email;
        }
        $user->save();

        // Update data customer
        $customer = Customers::where('user_id', $user->id)->first();
        if ($customer) {
            $customer->update([
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $request->phone ?? $customer->phone,
                'address' => $request->address ?? $customer->address,
            ]);
        }

        $profileData = [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'phone' => $customer ? $customer->phone : null,
            'address' => $customer ? $customer->address : null,
        ];

        return new BaseResource(true, 'Profil berhasil diperbarui', $profileData, 200);
    }

    /**
     * Delete user account
     */
    public function deleteAccount(Request $request)
{
    /** @var \App\Models\User $user */
    $user = Auth::user();

    if (!$user) {
        return new BaseResource(false, 'User tidak ditemukan', null, 404);
    }

    $request->validate([
        'password' => 'required|string',
    ]);

    // Verifikasi password
    if (!\Hash::check($request->password, $user->password)) {
        return new BaseResource(false, 'Password salah. Hapus akun dibatalkan.', null, 403);
    }

    // Hapus data customer terkait
    $customer = Customers::where('user_id', $user->id)->first();
    if ($customer) {
        $customer->orders()->delete();
        $customer->delete();
    }

    // Hapus semua token
    $user->tokens()->delete();

    // Hapus user
    $user->delete();

    return new BaseResource(true, 'Akun berhasil dihapus', null, 200);
}

    /**
     * Get user by ID (for admin)
     */
    public function show(string $id)
    {
        /** @var \App\Models\User $authUser */
        $authUser = Auth::user();

        // Hanya admin yang bisa melihat user lain
        if ($authUser->role !== 'admin' && $authUser->id != $id) {
            return new BaseResource(false, 'Tidak memiliki akses', null, 403);
        }

        $user = User::find($id);

        if (!$user) {
            return new BaseResource(false, 'User tidak ditemukan', null, 404);
        }

        $customer = Customers::where('user_id', $user->id)->first();

        $userData = [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'phone' => $customer ? $customer->phone : null,
            'address' => $customer ? $customer->address : null,
            'customer_id' => $customer ? $customer->id : null,
        ];

        return new BaseResource(true, 'Detail user berhasil diambil', $userData, 200);
    }
}