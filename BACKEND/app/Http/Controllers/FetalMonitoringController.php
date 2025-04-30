<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\FetalMonitoring;
use App\Models\PregnancyStage;
use Carbon\Carbon;

class FetalMonitoringController extends Controller
{
    public function index()
    {
        $monitorings = FetalMonitoring::orderBy('created_at', 'desc')->get();

        $data = $monitorings->map(function ($monitoring) {
            return $this->formatMonitoring($monitoring);
        });

        return response()->json([
            'message' => 'Data berhasil diambil',
            'data' => $data
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'nama_calon_bayi' => 'required|string',
            'berat_ibu' => 'required|numeric',
            'hpht' => 'required|date|before_or_equal:today',
            'bayi_kembar' => 'boolean'
        ]);

        $hpl = Carbon::parse($request->hpht)->addDays(280);

        $monitoring = FetalMonitoring::create([
            'nama_calon_bayi' => $request->nama_calon_bayi,
            'berat_ibu' => $request->berat_ibu,
            'hpht' => $request->hpht,
            'hpl' => $hpl,
            'bayi_kembar' => $request->bayi_kembar ?? false
        ]);

        return response()->json([
            'message' => 'Data berhasil disimpan',
            'data' => $this->formatMonitoring($monitoring)
        ]);
    }

    public function show($id)
    {
        $monitoring = FetalMonitoring::findOrFail($id);

        return response()->json([
            'message' => 'Data berhasil ditemukan',
            'data' => $this->formatMonitoring($monitoring)
        ]);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'nama_calon_bayi' => 'required|string',
            'berat_ibu' => 'required|numeric',
            'hpht' => 'required|date|before_or_equal:today',
            'bayi_kembar' => 'boolean'
        ]);

        $monitoring = FetalMonitoring::findOrFail($id);

        $hpl = Carbon::parse($request->hpht)->addDays(280);

        $monitoring->update([
            'nama_calon_bayi' => $request->nama_calon_bayi,
            'berat_ibu' => $request->berat_ibu,
            'hpht' => $request->hpht,
            'hpl' => $hpl,
            'bayi_kembar' => $request->bayi_kembar ?? false
        ]);

        return response()->json([
            'message' => 'Data berhasil diperbarui',
            'data' => $this->formatMonitoring($monitoring)
        ]);
    }

    public function destroy($id)
    {
        $monitoring = FetalMonitoring::findOrFail($id);
        $monitoring->delete();

        return response()->json([
            'message' => 'Data berhasil dihapus'
        ]);
    }

    // ✨ Helper: Format data monitoring
    private function formatMonitoring(FetalMonitoring $monitoring)
    {
        $hpht = Carbon::parse($monitoring->hpht);
        $today = Carbon::today();
        $weeks = floor($hpht->diffInDays($today) / 7);
        $days_until_due = $today->diffInDays(Carbon::parse($monitoring->hpl), false);

        // ✨ Tidak dibatasi 42 minggu di weeks
        $lookupWeek = min(max($weeks, 1), 42); // Untuk ambil data perkembangan di database, tetap max 42

        $stage = PregnancyStage::where('minggu_ke', $lookupWeek)->first();

        return [
            'id' => $monitoring->id,
            'nama_calon_bayi' => $monitoring->nama_calon_bayi,
            'days_until_due' => $days_until_due,
            'trimester' => $this->getTrimester($weeks),
            'hpl' => Carbon::parse($monitoring->hpl)->format('Y-m-d'), // ✨ Format tanggal saja
            'baby' => [
                'minggu_ke' => $weeks, // Asli minggu ke berapa (bisa lebih dari 42)
                'bentuk_janin' => $stage->bentuk_janin ?? null,
                'panjang_badan' => $stage->panjang_badan ?? null,
                'berat_badan' => $stage->berat_badan ?? null,
                'perkembangan' => $stage->perkembangan ?? null,
                'rekomendasi' => $stage->rekomendasi ?? null
            ]
        ];
    }

    // ✨ Helper: Tentukan trimester
    private function getTrimester($weeks)
    {
        if ($weeks <= 12) return 'Trimester 1';
        elseif ($weeks <= 27) return 'Trimester 2';
        else return 'Trimester 3';
    }
}
