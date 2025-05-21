<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Komunitas;
use App\Models\KomentarKomunitas;
use App\Models\Like;

class KomunitasController extends Controller
{
    public function index()
    {
        $Komunitas = Komunitas::all();

        return response()->json([
            'Komunitas' => $Komunitas
        ]);
    }

    public function indexid($id)
    {
        
        $result = komunitas::findOrFail($id);
        return response()->json($result);
    
        if (!$komunitas) {
            return response()->json([
                'message' => 'Data tidak ditemukan untuk post_id: ' . $request->post_id
            ], 404);
        }
    
        return response()->json([
            'Komunitas' => $komunitas
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
        $user = $request->user(); // pastikan middleware auth:api aktif di route
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
            }
            
        $request->validate([
            'judul' => 'required',
            'deskripsi' => 'required',
        ]);

        $komunitas = Komunitas::create([
            'user_id' => $user->id,
            'judul' => $request->judul,
            'deskripsi' => $request->deskripsi,
            'gambar' => $request->gambar,
            'apresiasi' => 0, 
            'komen' => 0, 
            
        ]);
        
        return response()->json([
            'status' => 'berhasil',
            'message' => 'Post created successfully',
            'data' => $komunitas
        ], 201);
    }

public function addComment(Request $request, $postId)
{
    $user = $request->user(); // pastikan middleware auth:api aktif di route
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
            }

    $request->validate([
        'komentar' => 'required|string|max:1000',
    ]);

    // Check if the post exists
    $post = Komunitas::find($postId);
    
    if (!$post) {
        return response()->json([
            'status' => 'error',
            'message' => 'Post not found'
        ], 404);
    }

    // Get current user from token (assume this is handled by auth middleware)
    $user = auth()->user();
    $userId = $user ? $user->id : null;

    // Create the comment
    try {
        $komentarKomunitas = KomentarKomunitas::create([
            'post_id' => $postId, // Use the URL parameter
            'user_id' => $user->id, // Simpan user ID dari JWT
            'komentar' => $request->komentar,
        ]);

        // Increment comment count on post
        $post->increment('komen');
        
        return response()->json([
            'status' => 'berhasil',
            'message' => 'Comment added successfully',
            'data' => $komentarKomunitas
        ], 201);
    } catch (\Exception $e) {
        \Log::error('Error adding comment: ' . $e->getMessage());
        
        return response()->json([
            'status' => 'error',
            'message' => 'Failed to add comment',
            'debug_info' => config('app.debug') ? $e->getMessage() : null
        ], 500);
    }
}

    public function getComments($postId)
    {
        // Check if post with this ID exists
        $post = Komunitas::find($postId);
        
        if (!$post) {
            return response()->json([
                'status' => 'error',
                'message' => 'Post not found'
            ], 404);
        }

        // Get all comments for this post
        // Make sure the column name matches (post_id not komunitas_id)
        $comments = KomentarKomunitas::where('post_id', $postId)
                            ->orderBy('created_at', 'desc')
                            ->with('user') // Include user relation if it exists
                            ->get();
        
        return response()->json([
            'status' => 'berhasil',
            'data' => $comments
        ], 200);
    }

    public function addLike(Request $request, $postId)
    {
        // Fixed the variable name from $Id to $postId
        // Check if post exists
        $post = Komunitas::find($postId);
        
        if (!$post) {
            return response()->json([
                'status' => 'error',
                'message' => 'Post not found'
            ], 404);
        }

        // Get current user from token (assume this is handled by auth middleware)
        $user = $request->user(); // pastikan middleware auth:api aktif di route
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
            }

        // Check if user already liked this post
        $existingLike = Like::where('post_id', $postId)
                            ->where('user_id', $user->id)
                            ->first();
        
        if ($existingLike) {
            // User already liked, so remove the like (unlike)
            $existingLike->delete();
            
            // Decrease like count
            $post->decrement('apresiasi');
            
            return response()->json([
                'status' => 'berhasil',
                'message' => 'Post unliked successfully',
                'is_liked' => false,
                'apresiasi' => $post->apresiasi // Return the updated count
            ], 200);
        } else {
            // User hasn't liked, add like
            Like::create([
                'post_id' => $postId, // Changed from komunitas_id to post_id to match frontend
                'user_id' => $user->id,
            ]);
            
            // Increase like count
            $post->increment('apresiasi');
            
            return response()->json([
                'status' => 'berhasil',
                'message' => 'Post liked successfully',
                'is_liked' => true,
                'apresiasi' => $post->apresiasi // Return the updated count
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