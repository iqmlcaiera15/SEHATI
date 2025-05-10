<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth:api', ['except' => ['login', 'register']]);
    }

    // public function register(Request $request)
    // {
    //     $validator = Validator::make($request->all(), [
    //         'name' => 'required|string|max:255',
    //         'email' => 'required|string|email|max:255|unique:users',
    //         'password' => 'required|string|min:6|confirmed',
    //     ]);

    //     if ($validator->fails()) {
    //         return response()->json($validator->errors(), 422);
    //     }

    //     $user = User::create([
    //         'name' => $request->name,
    //         'email' => $request->email,
    //         'password' => Hash::make($request->password),
    //     ]);

    //     $token = Auth::guard('api')->login($user);

    //     return response()->json([
    //         'status' => 'success',
    //         'message' => 'User registered successfully',
    //         'user' => $user,
    //         'authorization' => [
    //             'token' => $token,
    //             'type' => 'bearer',
    //         ]
    //     ]);
    // }

    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6|confirmed',
            'role' => 'required|string|in:ibu_hamil,bidan,dinas_kesehatan',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        // Create user based on role
        $userData = [
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role,
        ];

        switch ($request->role) {
            case 'ibu_hamil':
                // Validate ibu hamil specific fields
                $ibuHamilValidator = Validator::make($request->all(), [
                    'tanggal_lahir' => 'required|date',
                    'usia' => 'required|integer',
                    'alamat' => 'required|string',
                    'nomor_telepon' => 'required|string',
                ]);

                if ($ibuHamilValidator->fails()) {
                    return response()->json($ibuHamilValidator->errors(), 422);
                }

                // Add ibu hamil specific data
                $userData = array_merge($userData, [
                    'tanggal_lahir' => $request->tanggal_lahir,
                    'usia' => $request->usia,
                    'alamat' => $request->alamat,
                    'nomor_telepon' => $request->nomor_telepon,
                    'pendidikan_terakhir' => $request->pendidikan_terakhir,
                    'pekerjaan' => $request->pekerjaan,
                    'golongan_darah' => $request->golongan_darah,
                    'nama_suami' => $request->nama_suami,
                    'telepon_suami' => $request->telepon_suami,
                    'usia_suami' => $request->usia_suami,
                    'pekerjaan_suami' => $request->pekerjaan_suami,
                ]);
                break;

            case 'bidan':
                // Validate bidan specific fields
                $bidanValidator = Validator::make($request->all(), [
                    'nama_lengkap' => 'required|string',
                    'nik' => 'required|string|unique:users',
                    'nomor_str' => 'required|string|unique:users',
                    'nomor_sipb' => 'required|string|unique:users',
                ]);

                if ($bidanValidator->fails()) {
                    return response()->json($bidanValidator->errors(), 422);
                }

                // Add bidan specific data
                $userData = array_merge($userData, [
                    'role'=> 'bidan',
                    'nama_lengkap' => $request->nama_lengkap,
                    'nik' => $request->nik,
                    'tanggal_lahir' => $request->tanggal_lahir,
                    'alamat_ktp' => $request->alamat_ktp,
                    'nomor_telepon' => $request->nomor_telepon,
                    'pendidikan_terakhir' => $request->pendidikan_terakhir,
                    'nomor_str' => $request->nomor_str,
                    'masa_berlaku_str' => $request->masa_berlaku_str,
                    'nomor_sipb' => $request->nomor_sipb,
                    'masa_berlaku_sipb' => $request->masa_berlaku_sipb,
                    'tempat_praktik' => $request->tempat_praktik,
                    'alamat_praktik' => $request->alamat_praktik,
                    'telepon_tempat_praktik' => $request->telepon_tempat_praktik,
                    'spesialisasi' => $request->spesialisasi,
                ]);
                break;

            case 'dinas_kesehatan':
                // Validate dinas kesehatan specific fields
                $dinasValidator = Validator::make($request->all(), [
                    'nama_dinas' => 'required|string',
                    'alamat_kantor' => 'required|string',
                    'nomor_telepon' => 'required|string',
                    'nama_admin' => 'required|string',
                ]);

                if ($dinasValidator->fails()) {
                    return response()->json($dinasValidator->errors(), 422);
                }

                // Add dinas kesehatan specific data
                $userData = array_merge($userData, [
                    'nama_dinas' => $request->nama_dinas,
                    'alamat_kantor' => $request->alamat_kantor,
                    'nomor_telepon' => $request->nomor_telepon,
                    'website' => $request->website,
                    'logo' => $request->logo,
                    'nama_admin' => $request->nama_admin,
                    'nip' => $request->nip,
                    'jabatan' => $request->jabatan,
                    'foto_ktp' => $request->foto_ktp,
                ]);
                break;
        }

        $user = User::create($userData);
        $token = Auth::guard('web')->login($user);
    
        // Response berbeda berdasarkan role
        switch ($request->role) {
            case 'ibu_hamil':
                return response()->json([
                    'status' => 'success',
                    'message' => 'User registered successfully',
                    'user' => $user,
                    'authorization' => [
                        'token' => $token,
                        'type' => 'bearer',
                    ]
                ]);
    
            case 'bidan':
            case 'dinas_kesehatan':
                return redirect()->route('admin.dashboard')->with([
                    'status' => 'success',
                    'message' => 'Registrasi berhasil!'
                ]);
    
            default:
                return response()->json(['error' => 'Role tidak valid'], 400);
        }
    }


    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string|min:6',
        ]);
    
        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }
    
        $credentials = $request->only('email', 'password');
    
        if (!$token = Auth::guard('api')->attempt($credentials)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Unauthorized',
            ], 401);
        }
    
        $user = Auth::guard('api')->user();
        
        // Response berbeda berdasarkan role
        switch ($user->role) {
            case 'ibu_hamil':
                return response()->json([
                    'status' => 'success',
                    'message' => 'Login berhasil sebagai ibu hamil',
                    'user' => $user,
                    'authorization' => [
                        'token' => $token,
                        'type' => 'bearer',
                        'expires_in' => Auth::guard('api')->factory()->getTTL() * 60,
                    ]
                ]);
    
            case 'bidan':
            case 'dinas_kesehatan':
                // Login untuk session web juga
                Auth::guard('web')->login($user);
                
                if ($request->wantsJson()) {
                    return response()->json([
                        'status' => 'success',
                        'message' => 'Login berhasil sebagai '.$user->role,
                        'redirect_to' => route('admin.dashboard'),
                        'user' => $user,
                        'authorization' => [
                            'token' => $token,
                            'type' => 'bearer',
                        ]
                    ]);
                }
                
                return redirect()->route('admin.dashboard')->with([
                    'status' => 'success',
                    'message' => 'Login berhasil!'
                ]);
    
            default:
                return response()->json([
                    'status' => 'error',
                    'message' => 'Role tidak valid'
                ], 403);
        }
    }

    public function logout()
    {
        Auth::guard('api')->logout();
        return response()->json([
            'status' => 'success',
            'message' => 'Successfully logged out',
        ]);
    }

    public function refresh()
    {
        return response()->json([
            'status' => 'success',
            'user' => Auth::guard('api')->user(),
            'authorization' => [
                'token' => Auth::guard('api')->refresh(),
                'type' => 'bearer',
                'expires_in' => Auth::guard('api')->factory()->getTTL() * 60,
            ]
        ]);
    }

    public function me()
    {
        return response()->json(Auth::guard('api')->user());
    }
}