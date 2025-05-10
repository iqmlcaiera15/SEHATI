<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CheckRole
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next, ...$roles)
    {
        // Jika belum login, redirect ke login
        if (!auth()->check()) {
            return redirect()->route('login');
        }

        // Jika role user tidak ada dalam daftar roles yang diizinkan
        if (!in_array(auth()->user()->role, $roles)) {
            // Untuk API return JSON
            if ($request->expectsJson()) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Forbidden access for this role.'
                ], 403);
            }

            // Untuk web bisa redirect ke home atau abort
            abort(403, 'Unauthorized access for your role.');
        }

        return $next($request);
    }
}