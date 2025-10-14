<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;


class AuthController extends Controller
{
    // untuk melihat data user
    public function index(){
        $user = User::all();
        return response()->json([
            'code' => 200,
            'success' => 'success',
            'message' => 'List data user',
            'user' => $user
        ], 200);
    } 
    
    //
    public function register(Request $request)
    {
        // validasi input
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users',
            'password' => 'required|string|min:8',
        ]);

        // buat user baru
        /** @var \App\Models\User $user */
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password), // enkripsi password
        ]);

        // buat token untuk user
        $token = $user->createToken('auth_token')->plainTextToken;

        // kembalikan response
        return response()->json([
            'status' => 'success',
            'message' => 'User registered successfully',
            'token' => $token,
        ]);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if (Auth::attempt(['email' => $request->email, 'password' => $request->password])) {
            /** @var \App\Models\User|null $user */ 
            $user = Auth::user();
            $token = $user->createToken('token')->plainTextToken;

            // kalau berhasil
            return response()->json([
                'code' => 200,
                'status' => 'success',
                'message' => 'Login successful',
                'token' => $token,
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