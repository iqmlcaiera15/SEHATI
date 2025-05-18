<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Saldo;
use App\Models\User;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class SaldoController extends Controller
{
    /**
     * Tambah saldo untuk ibu hamil
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function Saldo(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::find($request->user_id);

        if (!$user) {
            return response()->json([
                'status' => false,
                'message' => 'Pengguna tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'status' => true,
            'message' => 'Informasi saldo pengguna berhasil diambil',
            'data' => [
                'user_id' => $user->id,
                'nama_ibu' => $user->nama,
                'saldo_total' => $user->saldo_total,
            ]
        ], 200);
    }

    public function tambahSaldo(Request $request)
    {
        // Validasi input
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id',
            'jumlah' => 'required|numeric|min:1',
            'keterangan' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        // Cek apakah user adalah ibu hamil
        $user = User::find($request->user_id);
        if (!$user || $user->role != 'ibu_hamil') {
            return response()->json([
                'status' => false,
                'message' => 'User bukan merupakan ibu hamil'
            ], 403);
        }

        DB::beginTransaction();
        try {
            // Buat transaksi saldo baru
            $saldo = new Saldo();
            $saldo->user_id = $request->user_id;
            $saldo->amount = $request->jumlah;
            $saldo->type = 'credit'; // kredit (penambahan)
            $saldo->keterangan = $request->keterangan ?? 'Penambahan saldo dari Dinas Kesehatan';
            $saldo->admin_id = Auth::id(); // ID admin yang memberikan saldo
            $saldo->save();

            // Update total saldo pada user
            $user->saldo_total = $user->saldo_total + $request->jumlah;
            $user->save();

            DB::commit();

            return response()->json([
                'status' => true,
                'message' => 'Saldo berhasil ditambahkan',
                'data' => [
                    'transaksi_id' => $saldo->id,
                    'user_id' => $user->id,
                    'nama_ibu' => $user->nama,
                    'jumlah' => $saldo->amount,
                    'saldo_total' => $user->saldo_total,
                    'tanggal' => $saldo->created_at
                ]
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'status' => false,
                'message' => 'Terjadi kesalahan saat menambah saldo',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Ambil riwayat transaksi saldo untuk ibu hamil tertentu
     *
     * @param  int  $userId
     * @return \Illuminate\Http\JsonResponse
     */
    public function getRiwayatSaldo($userId)
    {
        try {
            $user = User::findOrFail($userId);
            
            // Cek apakah user adalah ibu hamil
            if ($user->role != 'ibu_hamil') {
                return response()->json([
                    'status' => false,
                    'message' => 'User bukan merupakan ibu hamil'
                ], 403);
            }

            // Ambil semua riwayat transaksi
            $riwayat = Saldo::where('user_id', $userId)
                ->orderBy('created_at', 'desc')
                ->get();

            return response()->json([
                'status' => true,
                'message' => 'Riwayat saldo berhasil diambil',
                'data' => [
                    'user_id' => $user->id,
                    'nama_ibu' => $user->nama,
                    'saldo_total' => $user->saldo_total,
                    'transaksi' => $riwayat
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Terjadi kesalahan saat mengambil riwayat saldo',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Ambil daftar ibu hamil beserta saldo mereka
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getDaftarIbuHamil(Request $request)
    {
        try {
            $query = User::where('role', 'ibu_hamil');
            
            // Filter berdasarkan nama (jika ada)
            if ($request->has('nama')) {
                $query->where('nama', 'like', '%' . $request->nama . '%');
            }
            
            // Filter berdasarkan kelurahan/desa (jika ada)
            if ($request->has('kelurahan')) {
                $query->where('kelurahan', 'like', '%' . $request->kelurahan . '%');
            }

            $ibuHamil = $query->select('id', 'nama', 'nik', 'tanggal_lahir', 'alamat', 'kelurahan', 'kecamatan', 'saldo_total')
                ->orderBy('nama', 'asc')
                ->paginate(15);

            return response()->json([
                'status' => true,
                'message' => 'Daftar ibu hamil berhasil diambil',
                'data' => $ibuHamil
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Terjadi kesalahan saat mengambil daftar ibu hamil',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Batalkan transaksi saldo (hanya admin dengan level tertentu)
     *
     * @param  int  $transaksiId
     * @return \Illuminate\Http\JsonResponse
     */
    public function batalkanTransaksi($transaksiId)
    {
        // Cek hak akses (hanya admin dengan level tertentu)
        if (Auth::user()->role !== 'admin' || Auth::user()->admin_level < 2) {
            return response()->json([
                'status' => false,
                'message' => 'Tidak memiliki hak akses untuk membatalkan transaksi'
            ], 403);
        }

        DB::beginTransaction();
        try {
            // Ambil data transaksi
            $transaksi = Saldo::findOrFail($transaksiId);
            
            // Pastikan transaksi belum dibatalkan
            if ($transaksi->status === 'cancelled') {
                return response()->json([
                    'status' => false,
                    'message' => 'Transaksi sudah dibatalkan sebelumnya'
                ], 400);
            }

            // Cari user terkait
            $user = User::findOrFail($transaksi->user_id);
            
            // Update saldo user
            if ($transaksi->type === 'credit') {
                $user->saldo_total -= $transaksi->amount;
            } else {
                $user->saldo_total += $transaksi->amount;
            }
            $user->save();
            
            // Update status transaksi
            $transaksi->status = 'cancelled';
            $transaksi->cancelled_by = Auth::id();
            $transaksi->cancelled_at = now();
            $transaksi->save();

            DB::commit();
            
            return response()->json([
                'status' => true,
                'message' => 'Transaksi berhasil dibatalkan',
                'data' => [
                    'transaksi_id' => $transaksi->id,
                    'user_id' => $user->id,
                    'nama_ibu' => $user->nama,
                    'saldo_total_baru' => $user->saldo_total,
                ]
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'status' => false,
                'message' => 'Terjadi kesalahan saat membatalkan transaksi',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Laporan transaksi saldo (untuk admin)
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getLaporanTransaksi(Request $request)
    {
        try {
            $query = Saldo::with('user:id,nama,nik');
            
            // Filter berdasarkan rentang tanggal
            if ($request->has('tanggal_mulai')) {
                $query->whereDate('created_at', '>=', $request->tanggal_mulai);
            }
            
            if ($request->has('tanggal_akhir')) {
                $query->whereDate('created_at', '<=', $request->tanggal_akhir);
            }
            
            // Filter berdasarkan tipe transaksi
            if ($request->has('tipe')) {
                $query->where('type', $request->tipe);
            }
            
            // Filter berdasarkan status
            if ($request->has('status')) {
                $query->where('status', $request->status);
            }

            $transaksi = $query->orderBy('created_at', 'desc')
                ->paginate(20);
                
            // Hitung total
            $total = $query->sum('amount');

            return response()->json([
                'status' => true,
                'message' => 'Data laporan transaksi berhasil diambil',
                'data' => [
                    'transaksi' => $transaksi,
                    'total_nominal' => $total
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Terjadi kesalahan saat mengambil laporan',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}