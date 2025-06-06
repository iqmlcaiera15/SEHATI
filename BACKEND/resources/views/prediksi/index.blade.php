@extends('layouts.app')

@section('content')
<div class="container py-4">
    {{-- Header --}}
    <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
        <h2 class="fw-semibold text-primary">Riwayat Prediksi Metode Persalinan</h2>
        <a href="{{ route('bidan.prediksi.form') }}" class="btn btn-outline-primary btn-sm d-flex align-items-center px-3 py-2 fw-semibold shadow-sm">
            <i class="bi bi-plus me-1"></i> Prediksi Baru
        </a>
    </div>

    {{-- Filter --}}
    <form method="GET" action="{{ route('bidan.prediksi.index') }}" class="row g-3 align-items-end mb-4">
        <div class="col-md-3">
            <label for="method" class="form-label">Metode Persalinan</label>
            <select name="method" id="method" class="form-select shadow-sm">
                <option value="">Semua</option>
                <option value="normal" {{ request('method') == 'normal' ? 'selected' : '' }}>Normal</option>
                <option value="caesar" {{ request('method') == 'caesar' ? 'selected' : '' }}>Caesar</option>
            </select>
        </div>
        <div class="col-md-3">
            <label for="date" class="form-label">Tanggal Prediksi</label>
            <input type="date" name="date" id="date" class="form-control shadow-sm" value="{{ request('date') }}">
        </div>
        <div class="col-md-3 d-grid">
            <button type="submit" class="btn btn-outline-primary shadow-sm">Terapkan Filter</button>
        </div>
    </form>

    {{-- Tabel Data --}}
    <div class="card shadow-sm border-0">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover table-bordered align-middle mb-0">
                    <thead class="table-light text-center">
                        <tr>
                            <th>Usia Ibu</th>
                            <th>Tekanan Darah</th>
                            <th>Riwayat Persalinan</th>
                            <th>Riwayat Kesehatan</th>
                            <th>Posisi Janin</th>
                            <th>Kondisi Janin</th>
                            <th>Metode</th>
                            <th>Tanggal</th>
                            <th>Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="text-center">
                        @forelse($predictions as $prediction)
                            <tr>
                                <td>{{ $prediction->usia_ibu }} tahun</td>

                                {{-- Tekanan Darah --}}
                                <td>
                                    @php
                                        $tekanan = strtolower($prediction->tekanan_darah);
                                        $tekananClass = match($tekanan) {
                                            'normal' => 'text-primary',
                                            'rendah' => 'text-warning',
                                            'tinggi' => 'text-danger',
                                            default => 'text-muted',
                                        };
                                    @endphp
                                    <span class="{{ $tekananClass }}">{{ ucfirst($tekanan) }}</span>
                                </td>

                                {{-- Riwayat Persalinan --}}
                                <td>{{ ucfirst($prediction->riwayat_persalinan) }}</td>

                                {{-- Riwayat Kesehatan --}}
                                <td>{{ ucfirst($prediction->riwayat_kesehatan_ibu) }}</td>

                                {{-- Posisi Janin --}}
                                <td>
                                    @php
                                        $posisi = strtolower($prediction->posisi_janin);
                                        $posisiClass = match($posisi) {
                                            'normal' => 'text-primary',
                                            'lintang' => 'text-warning',
                                            'sungsang' => 'text-danger',
                                            default => 'text-muted',
                                        };
                                    @endphp
                                    <span class="{{ $posisiClass }}">{{ ucfirst($posisi) }}</span>
                                </td>

                                {{-- Kondisi Janin --}}
                                <td>{{ ucfirst($prediction->kondisi_kesehatan_janin) }}</td>

                                {{-- Metode --}}
                                <td>
                                    @php
                                        $metode = strtolower($prediction->metode_persalinan);
                                        $metodeClass = match($metode) {
                                            'normal' => 'text-info fw-semibold',
                                            'caesar' => 'text-danger fw-semibold',
                                            default => 'text-muted',
                                        };
                                    @endphp
                                    <span class="{{ $metodeClass }}">{{ ucfirst($metode) }}</span>
                                </td>

                                <td>{{ $prediction->created_at->format('d-m-Y') }}</td>
                                <td>
                                    <a href="{{ route('bidan.prediksi.show', $prediction->id) }}" class="btn btn-sm btn-outline-info me-1">Lihat</a>
                                    <form action="{{ route('bidan.prediksi.delete', $prediction->id) }}" method="POST" class="d-inline">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="btn btn-sm btn-outline-danger" onclick="return confirm('Yakin ingin menghapus?')">Hapus</button>
                                    </form>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="9" class="text-center text-muted py-4">Belum ada data prediksi.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection
