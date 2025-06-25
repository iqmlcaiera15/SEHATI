@extends('layouts.app')

@section('content')
<div class="container-fluid py-4">
    <!-- Header Section -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="card border-0 shadow-sm" style="background: linear-gradient(135deg, #4dbaff 0%, #1a87e3 100%);">
                <div class="card-body text-white">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h2 class="mb-2">
                                <i class="fas fa-baby me-2"></i>
                                Riwayat Prediksi Persalinan
                            </h2>
                            <p class="mb-0 opacity-75">Kelola dan pantau hasil prediksi metode persalinan</p>
                        </div>
                        <div class="text-end">
                            <div class="badge bg-light text-dark px-3 py-2 fs-6">
                                <i class="fas fa-users me-1"></i>
                                {{ $predictions->count() }} Data
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

        {{-- Tambahkan di sini --}}
    @if(session('success'))
        <div class="alert alert-success alert-dismissible fade show rounded-3 shadow-sm mb-4" role="alert" style="font-size: 1.07rem;">
            <i class="fas fa-check-circle me-2"></i>
            {{ session('success') }}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    @endif

<!-- Card Summary: Total Prediksi Normal & Caesar -->
<div class="row mb-4">
    <div class="col-md-3 mb-3">
        <div class="card border-0 shadow-sm text-center" style="border-radius: 15px;">
            <div class="card-body">
                <div class="rounded-circle mx-auto mb-2 d-flex align-items-center justify-content-center"
                    style="width: 56px; height: 56px; background: #e3f8ff;">
                    <i class="fas fa-baby text-info fs-4"></i>
                </div>
                <div class="fs-3 fw-bold">
                    {{ $allPredictions->filter(fn($p) => strtolower($p->metode_persalinan) == 'normal')->count() }}
                </div>
                <div class="text-muted small">Prediksi Normal</div>
            </div>
        </div>
    </div>
    <div class="col-md-3 mb-3">
        <div class="card border-0 shadow-sm text-center" style="border-radius: 15px;">
            <div class="card-body">
                <div class="rounded-circle mx-auto mb-2 d-flex align-items-center justify-content-center"
                    style="width: 56px; height: 56px; background: #ffe3ea;">
                    <i class="fas fa-baby text-danger fs-4"></i>
                </div>
                <div class="fs-3 fw-bold">
                    {{ $allPredictions->filter(fn($p) => strtolower($p->metode_persalinan) == 'caesar')->count() }}
                </div>
                <div class="text-muted small">Prediksi Caesar</div>
            </div>
        </div>
    </div>
    <div class="col-md-3 mb-3">
        <div class="card border-0 shadow-sm text-center" style="border-radius: 15px;">
            <div class="card-body">
                <div class="rounded-circle mx-auto mb-2 d-flex align-items-center justify-content-center"
                    style="width: 56px; height: 56px; background: #e4eaff;">
                    <i class="fas fa-users text-primary fs-4"></i>
                </div>
                <div class="fs-3 fw-bold">{{ $users->where('role','ibu_hamil')->count() }}</div>
                <div class="text-muted small">Total Ibu Hamil</div>
            </div>
        </div>
    </div>
    <div class="col-md-3 mb-3">
        <div class="card border-0 shadow-sm text-center" style="border-radius: 15px;">
            <div class="card-body">
                <div class="rounded-circle mx-auto mb-2 d-flex align-items-center justify-content-center"
                    style="width: 56px; height: 56px; background: #e3ffec;">
                    <i class="fas fa-database text-success fs-4"></i>
                </div>
                <div class="fs-3 fw-bold">{{ $allPredictions->count() }}</div>
                <div class="text-muted small">Total Prediksi</div>
            </div>
        </div>
    </div>
</div>

<!-- Filter & Action -->
<div class="row mb-4">
    <div class="col-12">
        <div class="row g-0 align-items-stretch">
            <!-- Tombol Tambah Prediksi Baru (kalem, kecil, tidak mencolok) -->
            <div class="col-auto d-flex align-items-center">
                <a href="{{ route('prediksi.form') }}"
                   class="btn btn-tambah-prediksi fw-semibold d-flex align-items-center gap-2 px-4 py-2"
                   style="font-size: 1.04rem; min-width: 170px;">
                    <i class="fas fa-plus-circle"></i>
                    Tambah Prediksi Baru
                </a>
            </div>
            <!-- Form Filter -->
            <div class="col">
                <form method="GET" action="{{ route('prediksi.index') }}" class="d-flex flex-wrap gap-2 align-items-end justify-content-end ms-md-2 mt-3 mt-md-0">
                    @if(Auth::user()->role === 'bidan')
                    <div>
                        <label for="user_id" class="form-label mb-1">Nama Ibu Hamil</label>
                        <select name="user_id" id="user_id" class="form-select shadow-sm rounded-3">
                            <option value="">Semua</option>
                            @foreach($users as $user)
                                @if($user->role === 'ibu_hamil')
                                    <option value="{{ $user->id }}" {{ request('user_id') == $user->id ? 'selected' : '' }}>
                                        {{ $user->name }}
                                    </option>
                                @endif
                            @endforeach
                        </select>
                    </div>
                    @endif
                    <div>
                        <label for="method" class="form-label mb-1">Metode Persalinan</label>
                        <select name="method" id="method" class="form-select shadow-sm rounded-3">
                            <option value="">Semua</option>
                            <option value="normal" {{ request('method') == 'normal' ? 'selected' : '' }}>Normal</option>
                            <option value="caesar" {{ request('method') == 'caesar' ? 'selected' : '' }}>Caesar</option>
                        </select>
                    </div>
                    <div>
                        <label for="hpl" class="form-label mb-1">HPL</label>
                        <input type="date" name="hpl" id="hpl" class="form-control shadow-sm rounded-3" value="{{ request('hpl') }}">
                    </div>
                    <div class="d-flex align-items-end gap-2 mb-2">
                        <button type="submit" class="btn btn-danger d-flex align-items-center gap-2 shadow-sm rounded-3 px-3">
                            <i class="fas fa-filter"></i>
                            Terapkan Filter
                        </button>
                        <a href="{{ route('prediksi.index') }}" class="btn btn-outline-secondary d-flex align-items-center gap-2 shadow-sm rounded-3 px-3">
                            <i class="fas fa-undo"></i>
                            Reset Filter
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>



    <!-- Main Table -->
    <div class="row">
        <div class="col-12">
            <div class="card border-0 shadow-sm" style="border-radius: 15px;">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0" style="border-radius: 12px; overflow: hidden;">
                            <thead class="bg-light">
                                <tr>
                                    <th class="border-0 py-3 px-4"><i class="fas fa-user me-2"></i>Nama Ibu Hamil</th>
                                    <th class="border-0 py-3"><i class="fas fa-stethoscope me-2"></i>Metode</th>
                                    <th class="border-0 py-3"><i class="fas fa-balance-scale me-2"></i>Faktor</th>
                                    <th class="border-0 py-3"><i class="fas fa-percentage me-2"></i>Confidence</th>
                                    <th class="border-0 py-3"><i class="fas fa-calendar me-2"></i>HPL</th>
                                    <th class="border-0 py-3"><i class="fas fa-clock me-2"></i>Waktu Prediksi</th>
                                    <th class="border-0 py-3 text-center"><i class="fas fa-cogs me-2"></i>Aksi</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse($predictions as $prediction)
                                    <tr class="border-bottom">
                                        <td class="py-3 px-4">
                                            {{-- Logo profile abjad --}}
                                            <div class="d-flex align-items-center">
                                                <div class="rounded-circle me-3 d-flex align-items-center justify-content-center"
                                                    style="width: 40px; height: 40px; background: linear-gradient(45deg, #667eea, #764ba2); color: white; font-size: 1.3rem;">
                                                    {{ strtoupper(substr($prediction->user->name ?? '', 0, 1)) }}
                                                </div>
                                                <span>{{ $prediction->user->name ?? '-' }}</span>
                                            </div>
                                        </td>
                                        <td class="py-3">
                                            <span class="fw-semibold
                                                @if(strtolower($prediction->metode_persalinan) == 'normal') text-info
                                                @elseif(strtolower($prediction->metode_persalinan) == 'caesar') text-danger
                                                @else text-muted @endif">
                                                {{ ucfirst($prediction->metode_persalinan) }}
                                            </span>
                                        </td>
                                        <td class="py-3">
                                            {{ $prediction->faktor ?? '-' }}
                                        </td>
                                        <td class="py-3">
                                            {{ is_numeric($prediction->confidence) ? round($prediction->confidence) . '%' : '-' }}
                                        </td>
                                        <td class="py-3">
                                            {{ $prediction->hpl && $prediction->hpl->hpl
                                                ? \Carbon\Carbon::parse($prediction->hpl->hpl)->format('d-m-Y')
                                                : '-' }}
                                        </td>
                                        <td class="py-3">
                                            <div>
                                                <div class="fw-bold">{{ \Carbon\Carbon::parse($prediction->created_at)->format('d M Y') }}</div>
                                                <small class="text-muted">{{ \Carbon\Carbon::parse($prediction->created_at)->format('H:i') }}</small>
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
                                        <td colspan="7" class="text-center text-muted py-5">
                                            <i class="fas fa-baby text-muted mb-3" style="font-size: 3rem; opacity: 0.3;"></i>
                                            <br>
                                            <span class="d-block mt-2">Belum ada data prediksi.</span>
                                        </td>
                                    </tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Custom Styles -->
<style>
    .btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(0,0,0,0.15) !important;
    }
    .table-hover tbody tr:hover {
        background-color: rgba(77, 186, 255, 0.07);
        transform: scale(1.002);
        transition: all 0.2s ease;
    }
    .card, .btn, .badge {
        transition: all 0.3s ease;
    }
    a[href*="prediksi.form"]:hover {
        background: linear-gradient(45deg, #1a87e3, #4dbaff) !important;
    }
</style>
@endsection
