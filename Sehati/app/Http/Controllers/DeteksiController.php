<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\DeteksiPenyakit;

class AddonsController extends Controller
{
    //
    public function index()
    {
        $addons = Addons::all();

        return view('admin.sparepart.index', compact('addons'));
    }

    public function detail($id)
    {
        $addon = Addons::find($id);

        return response()->json([
            'add-ons' => $addon
        ]);
    }

    public function create()
    {
        return view('admin.sparepart.create');
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required',
            'description' => 'required',
            'price' => 'required',
            'stock' => 'required'
        ]);

        Addons::create([
            'name' => $request->name,
            'description' => $request->description,
            'price' => $request->price,
            'stock' => $request->stock
        ]);

        return redirect()->route('admin.sparepart.index')->with('success', 'Barang berhasil ditambahkan');
    }

    public function edit($id)
    {
        $addons = Addons::find($id);

        return view('admin.sparepart.edit', compact('addons'));
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'name' => 'required',
            'description' => 'required',
            'price' => 'required',
            'stock' => 'required'
        ]);

        $addon = Addons::find($id);
        $addon->update([
            'name' => $request->name,
            'description' => $request->description,
            'price' => $request->price,
            'stock' => $request->stock
        ]);

        return redirect()->route('admin.sparepart.index')->with('success', 'Barang berhasil diubah');
    }

    public function destroy($id)
    {
        $addon = Addons::find($id);
        $addon->delete();

        return redirect()->route('admin.sparepart.index')->with('success', 'Barang berhasil dihapus');
    }
}
