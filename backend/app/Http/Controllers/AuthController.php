<?php

namespace App\Http\Controllers;

use App\Http\Resources\BaseResource;
use App\Models\User;
use App\Models\Customers;
use App\Models\EmailVerification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    public function sendVerificationCode(Request $request)
    {
        $request->validate(['email' => 'required|email|unique:users,email']);

        $otp = rand(100000, 999999);

        EmailVerification::updateOrCreate(
            ['email' => $request->email],
            [
                'otp' => $otp,
                'expires_at' => Carbon::now()->addMinutes(10)
            ]
        );

        Mail::raw("Kode verifikasi kamu adalah: $otp", function ($message) use ($request) {
            $message->to($request->email)
                    ->subject('Kode Verifikasi Akun CampGear');
        });

        return new BaseResource(true, 'Kode verifikasi dikirim ke email', null, 200);
    }

    public function verifyCode(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required'
        ]);

        $verification = EmailVerification::where('email', $request->email)->first();

        if (!$verification) {
            return response()->json([
                'status' => 'error',
                'message' => 'Email tidak ditemukan.'
            ], 404);
        }

        if ($verification->otp != $request->otp) {
            return response()->json([
                'status' => 'error',
                'message' => 'Kode verifikasi salah.'
            ], 400);
        }

        if (Carbon::now()->greaterThan($verification->expires_at)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Kode verifikasi sudah kedaluwarsa.'
            ], 400);
        }

        // Jika benar, hapus kode verifikasi agar tidak bisa digunakan lagi
        $verification->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Kode verifikasi benar, silakan lanjutkan registrasi.'
        ], 200);
    }
    
    public function register(Request $request)
    {
        // validasi input
        $validator = Validator::make($request->all(),[
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|unique:users',
            'password' => 'required|string|min:8',

            // column for personel
            'phone' => 'required|string|max:50',
            'address' => 'nullable',
        ]);
        
        if($validator->fails()) {
            return new BaseResource(false, 'Validasi gagal', $validator->errors(), 422);
        }

        // buat user baru
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password), // enkripsi password
        ]);

        $customers = Customers::create([
        'name' => $user->name,
        'email' => $user->email,
        'phone' => $request->phone,
        'address' => $request->address,
        'user_id' => $user->id,
        ]);

        // buat token untuk user
        $token = $user->createToken('auth_token')->plainTextToken;

        // kembalikan response
        return response()->json([
            'status' => 'success',
            'message' => 'User registered successfully',
            'token' => $token,
            'user' => $user,
            'customers' => $customers
        ]);
    }
    
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if (Auth::attempt(['email' => $request->email, 'password' => $request->password])) {
            /** @var \App\Models\User $user */
            $user = Auth::user();
            $token = $user->createToken('token')->plainTextToken;
            $role = Auth::user()->role;

            // kalau berhasil
            return response()->json([
                'code' => 200,
                'status' => 'success',
                'message' => 'Login successful',
                'token' => $token,
                'role' => $role,
            ], 200);
        }

        // kalau gagal
        return response()->json([
            'code' => 401,
            'status' => 'error',
            'message' => 'Login failed',
        ], 401);
    }
}
