<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class PeranMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, $peran): Response
    {
        if(Auth::check()){
            // bisa kirim multi role seperti "admin-customer"
            $allowedRoles = explode('-', $peran);

            // klasifikasi peran diambil dari kolom role
            if(in_array(Auth::user()->role, $allowedRoles)){
                return $next($request);
            } 
        }

        
        return response()->json([
            'code' => 403,
            'status' => 'error',
            'message' => 'Access Denied — Anda tidak punya hak untuk mengakses route ini.'
        ], 403);
    }
}
