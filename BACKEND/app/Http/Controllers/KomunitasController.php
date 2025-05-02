<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Komunitas;
use App\Models\KomentarKomunitas;

class KomunitasController extends Controller
{
    public function index()
    {
        $Komunitas = Komunitas::all();

        return response()->json([
            'Komunitas' => $Komunitas
        ]);
    }
    
     public function indexlatest()
    {
        $Komunitas = Komunitas::latest()->first();

        return response()->json([
            'Komunitas' => $Komunitas
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            // 'user_id' => 'required',
            'judul' => 'required',
            'deskripsi' => 'required',
        ]);

        $komunitas = Komunitas::create([
            // 'user_id' => $request->user_id,
            'judul' => $request->judul,
            'deskripsi' => $request->deskripsi,
            'gambar' => $request->gambar,
            'likes' => 0, // Inisialisasi dengan 0 likes
            
        ]);
        
        return response()->json([
            'status' => 'berhasil',
            'message' => 'Post created successfully',
            'data' => $komunitas
        ], 201);
    }

    public function addComment(Request $request, $postId)
    {
        $request->validate([
            // 'user_id' => 'required',
            'komentar' => 'required',
        ]);

        // Cek apakah post dengan id tersebut ada
        $post = Komunitas::find($postId);
        
        if (!$post) {
            return response()->json([
                'status' => 'error',
                'message' => 'Post not found'
            ], 404);
        }

        // Buat komentar
        $komentarkomunitas = KomentarKomunitas::create([
            // 'komunitas_id' => $postId,
            // 'user_id' => $request->user_id,
            'komentar' => $request->komentar,
        ]);

        // Update jumlah komentar di tabel Komunitas
        $post->increment('komen');
        
        return response()->json([
            'status' => 'berhasil',
            'message' => 'Comment added successfully',
            // 'data' => $komentar
        ], 201);
    }

    public function getComments($postId)
    {
        // Cek apakah post dengan id tersebut ada
        $post = Komunitas::find($postId);
        
        if (!$post) {
            return response()->json([
                'status' => 'error',
                'message' => 'Post not found'
            ], 404);
        }

        // Ambil semua komentar untuk post ini
        $comments = Komentar::where('komunitas_id', $postId)
                            ->orderBy('created_at', 'komentar')
                            ->with('user') // Tambahkan relasi user jika ada
                            ->get();
        
        return response()->json([
            'status' => 'berhasil',
            'data' => $comments
        ], 200);
    }

    public function addLike(Request $request, $postId)
    {
        $request->validate([
            'user_id' => 'required',
        ]);

        // Cek apakah post dengan id tersebut ada
        $post = Komunitas::find($postId);
        
        if (!$post) {
            return response()->json([
                'status' => 'error',
                'message' => 'Post not found'
            ], 404);
        }

        // Cek apakah user sudah memberikan like pada post ini
        $existingLike = Like::where('komunitas_id', $postId)
                            ->where('user_id', $request->user_id)
                            ->first();
        
        if ($existingLike) {
            // User sudah like, jadi kita hapus like-nya (unlike)
            $existingLike->delete();
            
            // Kurangi jumlah likes di tabel Komunitas
            $post->decrement('likes');
            
            return response()->json([
                'status' => 'berhasil',
                'message' => 'Post unliked successfully',
                'is_liked' => false
            ], 200);
        } else {
            // User belum like, tambahkan like
            Like::create([
                'komunitas_id' => $postId,
                'user_id' => $request->user_id,
            ]);
            
            // Tambah jumlah likes di tabel Komunitas
            $post->increment('likes');
            
            return response()->json([
                'status' => 'berhasil',
                'message' => 'Post liked successfully',
                'is_liked' => true
            ], 201);
        }
    }

    public function checkLikeStatus(Request $request, $postId)
    {
        $request->validate([
            'user_id' => 'required',
        ]);

        // Cek apakah user sudah memberikan like pada post ini
        $existingLike = Like::where('komunitas_id', $postId)
                            ->where('user_id', $request->user_id)
                            ->exists();
        
        return response()->json([
            'status' => 'berhasil',
            'is_liked' => $existingLike
        ], 200);
    }

    public function deleteAll()
    {
        Komunitas::truncate(); 
        return response()->json([
            'status' => 'success',
            'message' => 'All data deleted successfully'
        ], 200);
    }

   
    public function deleteById($id)
    {
        $komunitas = Komunitas::find($id);

        if (!$komunitas) {
            return response()->json([
                'status' => 'error',
                'message' => 'Data not found'
            ], 404);
        }

        $komunitas->delete();
        return response()->json([
            'status' => 'success',
            'message' => 'Data deleted successfully'
        ], 200);
    }
}