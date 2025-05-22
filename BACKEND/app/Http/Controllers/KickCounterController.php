<?php
namespace App\Http\Controllers;
use Illuminate\Http\Request;
use App\Models\KickCounter;

class KickCounterController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth:sanctum');
    }
    
    public function store(Request $request)
    {
        try {
            $request->validate([
                'kick_count' => 'required|integer|min:1',
                'duration' => 'required|integer|min:0',
            ]);
    
            $kickCounter = KickCounter::create([
                'user_id' => auth()->id(),
                'kick_count' => $request->kick_count,
                'recorded_at' => now(),
                'duration' => $request->duration,
            ]);
    
            return response()->json([
                'message' => 'Data berhasil disimpan',
                'data' => $kickCounter
            ], 201);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'message' => 'Validasi gagal',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Terjadi kesalahan',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    public function index()
    {
        $kickCounter = KickCounter::where('user_id', auth()->id())->get();
        
        return response()->json([
            'data' => $kickCounter
        ]);
    }
}
