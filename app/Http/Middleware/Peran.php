<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Support\Facades\Auth;

class Peran
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, $peran): Response
    {
        // jika user teridentifikasi memiliki akun maka klasifikasi perannya
        if(Auth::check()){
            $allowedRoles = explode('-', $peran);
            // klasifikasi peran diambil dari kolom role
            if(in_array(Auth::user()->role, $allowedRoles)){
                return $next($request);
            } 
        }
        return response()->json([
            'code' => 403,
            'status' => 'error',
            'message' => 'Not Access'
        ], 403);
    }
}
