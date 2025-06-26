@extends('layouts.app')

@section('content')
<div class="container-fluid py-4">

    <!-- HEADER -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="card border-0 shadow-sm" style="background: linear-gradient(100deg, #7c84e4 0%, #55b8ff 100%); border-radius: 10px;">
                <div class="card-body text-white d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-1" style="font-weight:600;">
                            <i class="fas fa-baby me-2"></i>Riwayat Prediksi Persalinan
                        </h2>
                        <p class="mb-0 opacity-75">Kelola dan pantau hasil prediksi metode persalinan pasien</p>
                    </div>
                    <span class="badge bg-light text-dark px-3 py-2 fs-6" style="font-size:1.05rem;">
                        <i class="fas fa-users me-1"></i>
                        {{ $users->where('role', 'ibu_hamil')->count() }} Pasien
                    </span>
                </div>
            </div>
        </div>
    </div>

    <!-- ACTIONS (hapus semua, export) -->
    <div class="row mb-3">
        <div class="col-12 d-flex flex-wrap align-items-center gap-2">
            <form action="{{ route('prediksi.bulkDelete') }}" method="POST" class="d-inline">
                @csrf @method('DELETE')
                <button type="submit" class="btn btn-outline-danger d-flex align-items-center gap-2 fw-semibold px-4 py-2" onclick="return confirm('Yakin hapus semua data prediksi?');">
                    <i class="fas fa-trash"></i> Hapus Semua
                </button>
            </form>
            <a href="{{ route('prediksi.export') }}" class="btn btn-outline-primary d-flex align-items-center gap-2 fw-semibold px-4 py-2">
                <i class="fas fa-download"></i> Export Data
            </a>
        </div>
    </div>

    <!-- FILTER BAR -->
    <div class="row mb-3">
        <div class="col-12">
            <div class="card border-0 shadow-sm p-3" style="border-radius: 12px;">
                <form method="GET" action="{{ route('prediksi.index') }}" class="d-flex flex-wrap align-items-end gap-3 mb-0">
                    <div>
                        <label class="form-label fw-semibold mb-1"><i class="fas fa-calendar-alt me-1"></i> Filter Tanggal</label>
                        <input type="date" name="tanggal" class="form-control" value="{{ request('tanggal') }}" style="min-width:160px;">
                    </div>
                    <div>
                        <label class="form-label fw-semibold mb-1"><i class="fas fa-filter me-1"></i> Filter Hasil</label>
                        <select name="hasil" class="form-select" style="min-width:180px;">
                            <option value="">-- Semua --</option>
                            <option value="normal" {{ request('hasil')=='normal' ? 'selected' : '' }}>Normal</option>
                            <option value="caesar" {{ request('hasil')=='caesar' ? 'selected' : '' }}>Caesar</option>
                        </select>
                    </div>
                    <div class="ms-auto d-flex gap-2 flex-grow-1 flex-md-grow-0 align-items-end">
                        <input type="text" name="search" class="form-control" style="min-width:210px;" placeholder="Cari nama pasien..." value="{{ request('search') }}">
                        <button type="submit" class="btn btn-primary px-4 d-flex align-items-center gap-2">
                            <i class="fas fa-search"></i> Filter
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- TOMBOL TAMBAH & TITLE DATA -->
    <div class="row mb-2">
        <div class="col-12 d-flex justify-content-between align-items-center">
            <div class="fw-semibold fs-5 d-flex align-items-center gap-2">
                <i class="fas fa-table"></i>
                Data Prediksi Metode Persalinan Pasien
            </div>
            <a href="{{ route('prediksi.form') }}"
                class="btn d-flex align-items-center gap-2 px-4 py-2 fw-semibold"
                style="background: linear-gradient(45deg, #44d1fc, #7c84e4); color: white; border-radius: 7px;">
                <i class="fas fa-plus-circle"></i> Tambah Prediksi Baru
            </a>
        </div>
    </div>

    <!-- DATA TABLE -->
    <div class="row">
        <div class="col-12">
            <div class="card border-0 shadow-sm" style="border-radius: 15px;">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0 align-middle" style="border-radius: 12px; overflow: hidden;">
                            <thead class="bg-light">
                                <tr>
                                    <th class="border-0 py-3 px-4"><i class="fas fa-user me-2"></i>Pasien</th>
                                    <th class="border-0 py-3"><i class="fas fa-stethoscope me-2"></i>Hasil Prediksi</th>
                                    <th class="border-0 py-3"><i class="fas fa-percentage me-2"></i>Confidence</th>
                                    <th class="border-0 py-3"><i class="fas fa-balance-scale me-2"></i>Faktor</th>
                                    <th class="border-0 py-3"><i class="fas fa-calendar me-2"></i>Tanggal</th>
                                    <th class="border-0 py-3 text-center"><i class="fas fa-cogs me-2"></i>Aksi</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse($predictions as $prediction)
                                    <tr class="border-bottom">
                                        <td class="py-3 px-4">
                                            <div class="d-flex align-items-center gap-3">
                                                <div class="rounded-circle d-flex align-items-center justify-content-center"
                                                    style="width: 36px; height: 36px; background: linear-gradient(45deg, #667eea, #7c84e4); color: white; font-size: 1.13rem;">
                                                    {{ strtoupper(substr($prediction->user->name ?? '', 0, 1)) }}
                                                </div>
                                                <div>
                                                    <div class="fw-semibold">{{ $prediction->user->name ?? '-' }}</div>
                                                    <div class="text-muted small">{{ $prediction->usia_ibu }} tahun</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td class="py-3">
                                            @if(strtolower($prediction->metode_persalinan) == 'normal')
                                                <span class="badge bg-info text-white px-3 py-2" style="font-size:1.03rem;">Normal</span>
                                            @elseif(strtolower($prediction->metode_persalinan) == 'caesar')
                                                <span class="badge bg-danger text-white px-3 py-2" style="font-size:1.03rem;">Caesar</span>
                                            @else
                                                <span class="badge bg-secondary px-3 py-2">-</span>
                                            @endif
                                        </td>
                                        <td class="py-3">
                                            <span class="badge bg-primary text-white px-3 py-2" style="font-size:1.03rem;">
                                                {{ is_numeric($prediction->confidence) ? round($prediction->confidence) . '%' : '-' }}
                                            </span>
                                        </td>
                                        <td class="py-3">
                                            {{ $prediction->faktor ?? '-' }}
                                        </td>
                                        <td class="py-3">
                                            <div>
                                                <div class="fw-bold">{{ \Carbon\Carbon::parse($prediction->created_at)->translatedFormat('d M Y') }}</div>
                                                <div class="text-muted small">{{ \Carbon\Carbon::parse($prediction->created_at)->format('H:i') }}</div>
                                            </div>
                                        </td>
                                        <td class="py-3 text-center">
                                            <div class="btn-group" role="group">
                                                <a href="{{ route('prediksi.show', $prediction->id) }}"
                                                    class="btn btn-sm btn-outline-primary" style="border-radius: 8px 0 0 8px;">
                                                    <i class="fas fa-eye"></i>
                                                </a>
                                                <form action="{{ route('prediksi.delete', $prediction->id) }}" method="POST"
                                                    onsubmit="return confirm('Yakin ingin menghapus?')">
                                                    @csrf
                                                    @method('DELETE')
                                                    <button type="submit" class="btn btn-sm btn-outline-danger" style="border-radius: 0 8px 8px 0;">
                                                        <i class="fas fa-trash"></i>
                                                    </button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td colspan="6" class="text-center text-muted py-5">
                                            <i class="fas fa-baby text-muted mb-3" style="font-size: 3rem; opacity: 0.3;"></i>
                                            <br>
                                            <span class="d-block mt-2">Belum ada data prediksi.</span>
                                        </td>
                                    </tr>
                                @endforelse
                            </tbody>
                        </table>
                        <!-- PAGINATION -->
                        <div class="mt-3 px-3">
                            {{ $predictions->links('pagination::bootstrap-4') }}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Custom Styles -->
<style>
    .btn, .badge, .card { transition: all .2s;}
    .btn:hover { filter: brightness(1.07); }
    .table-hover tbody tr:hover {
        background-color: rgba(77, 186, 255, 0.07);
        transform: scale(1.005);
        transition: all 0.15s;
    }
    .card, .btn, .badge { transition: all 0.3s ease; }
    @media (max-width: 950px) {
        .d-flex.flex-wrap.align-items-end.gap-4 {
            flex-direction: column;
            align-items: stretch;
            gap: 16px !important;
        }
        .d-flex.flex-wrap.align-items-end.gap-4 > * {
            width: 100%;
        }
    }
</style>
@endsection
