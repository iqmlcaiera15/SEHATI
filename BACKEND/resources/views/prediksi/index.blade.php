@extends('layouts.app')

@section('content')
<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
        <h2 class="fw-semibold text-primary">Daftar Prediksi Metode Persalinan</h2>
        <a href="{{ route('prediksi.form') }}"
           class="btn btn-primary btn-lg d-flex align-items-center gap-2 px-4 py-2 fw-semibold shadow"
           style="background: linear-gradient(90deg, #4dbaff 0%, #1a87e3 100%); border: none;">
            <i class="bi bi-file-earmark-plus fs-4"></i>
            Prediksi Baru
        </a>
    </div>

    {{-- Filter --}}
    <form method="GET" action="{{ route('prediksi.index') }}" class="row g-3 align-items-end mb-4">
        @if(Auth::user()->role === 'bidan')
        <div class="col-md-4">
            <label for="user_id" class="form-label">Nama Ibu Hamil</label>
            <select name="user_id" id="user_id" class="form-select shadow-sm">
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

        <div class="col-md-4">
            <label for="method" class="form-label">Metode Persalinan</label>
            <select name="method" id="method" class="form-select shadow-sm">
                <option value="">Semua</option>
                <option value="normal" {{ request('method') == 'normal' ? 'selected' : '' }}>Normal</option>
                <option value="caesar" {{ request('method') == 'caesar' ? 'selected' : '' }}>Caesar</option>
            </select>
        </div>
        <div class="col-md-4">
            <label for="hpl" class="form-label">HPL</label>
            <input type="date" name="hpl" id="hpl" class="form-control shadow-sm" value="{{ request('hpl') }}">
        </div>
        <div class="col-md-12 d-grid mt-2">
            <button type="submit" class="btn btn-danger d-flex align-items-center justify-content-center gap-2 shadow-sm">
                <i class="bi bi-funnel-fill"></i>
                Terapkan Filter
            </button>
        </div>
    </form>

    <div class="card shadow-sm border-0">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover table-bordered align-middle mb-0">
                    <thead class="table-light text-center">
                        <tr>
                            <th>Nama Ibu Hamil</th>
                            <th>Metode</th>
                            <th>Faktor</th>
                            <th>Confidence</th>
                            <th>HPL</th>
                            <th>Waktu Prediksi</th> <!-- kolom baru -->
                            <th>Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="text-center">
                        @forelse($predictions as $prediction)
                            <tr>
                                <td>{{ $prediction->user->name ?? '-' }}</td>
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
                                <td>
                                    {{ $prediction->faktor ?? '-' }}
                                </td>
                                <td>
                                    {{ is_numeric($prediction->confidence) ? round($prediction->confidence) . '%' : '-' }}
                                </td>
                                <td>
                                    {{ $prediction->hpl && $prediction->hpl->hpl
                                        ? \Carbon\Carbon::parse($prediction->hpl->hpl)->format('d-m-Y')
                                        : '-' }}
                                </td>
                                <td>
                                    {{ $prediction->created_at ? \Carbon\Carbon::parse($prediction->created_at)->format('d-m-Y H:i') : '-' }}
                                </td>
                                <td>
                                    <div class="dropdown">
                                        <button class="btn btn-sm btn-outline-primary shadow-sm" type="button" id="aksiDropdown{{ $prediction->id }}" data-bs-toggle="dropdown" aria-expanded="false">
                                            <i class="bi bi-three-dots-vertical fs-5"></i>
                                        </button>
                                        <ul class="dropdown-menu" aria-labelledby="aksiDropdown{{ $prediction->id }}">
                                            <li>
                                                <a class="dropdown-item d-flex align-items-center gap-2 text-primary fw-semibold" href="{{ route('prediksi.show', $prediction->id) }}">
                                                    <i class="bi bi-eye"></i>
                                                    <span>Lihat Detail</span>
                                                </a>
                                            </li>
                                            <li>
                                                <form action="{{ route('prediksi.delete', $prediction->id) }}" method="POST" onsubmit="return confirm('Yakin ingin menghapus?')">
                                                    @csrf
                                                    @method('DELETE')
                                                    <button class="dropdown-item d-flex align-items-center gap-2 text-danger fw-semibold" type="submit">
                                                        <i class="bi bi-trash"></i>
                                                        <span>Hapus</span>
                                                    </button>
                                                </form>
                                            </li>
                                        </ul>
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="7" class="text-center text-muted py-4">Belum ada data prediksi.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection
