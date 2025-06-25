@extends('layouts.app')

@section('content')
@php
    $method = strtolower($prediction->metode_persalinan);
    $isCaesar = $method === 'caesar';
    $badgeClass = $isCaesar ? 'bg-danger bg-opacity-10 text-danger border-danger' : 'bg-primary bg-opacity-10 text-primary border-primary';
    $hpl = $prediction->hpl && $prediction->hpl->hpl
        ? \Carbon\Carbon::parse($prediction->hpl->hpl)->translatedFormat('d F Y')
        : '-';
@endphp

<div class="container-fluid py-4">

    <!-- Header Section -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="card border-0 shadow-sm" style="background: linear-gradient(135deg, #4dbaff 0%, #1a87e3 100%); border-radius: 15px;">
                <div class="card-body text-white">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h2 class="mb-2">
                                <i class="fas fa-baby me-2"></i>
                                Hasil Prediksi Persalinan
                            </h2>
                            <span class="opacity-75">Detail hasil prediksi metode persalinan berdasarkan data terbaru</span>
                        </div>
                        <a href="{{ route('prediksi.index') }}" class="btn btn-outline-light d-flex align-items-center shadow-sm px-4 rounded-3 fw-semibold">
                            <i class="fas fa-arrow-left me-2"></i> Riwayat
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Card Hasil Prediksi -->
    <div class="row justify-content-center">
        <div class="col-lg-8 col-md-10">
            <div class="card border-0 shadow-lg rounded-4 overflow-hidden" style="background: linear-gradient(110deg, #f8fbff 70%, #e8f0ff 100%); border-radius: 18px;">
                <div class="card-body p-0">

                    <!-- Badge & Prediksi -->
                    <div class="text-center py-4" style="background: #fff; border-radius: 18px 18px 0 0;">
                        <span class="badge px-4 py-2 fw-bold rounded-pill border {{ $badgeClass }}" style="font-size: 1.15rem; box-shadow: 0 2px 12px rgba(34,139,230,0.07); letter-spacing: 1px;">
                            {{ ucfirst($prediction->metode_persalinan) }}
                        </span>
                        <div class="fw-bold mt-3" style="font-size: 2rem; color: #205685; letter-spacing: 0.5px;">
                            {{ $isCaesar ? 'Caesar' : 'Normal' }}
                        </div>
                        <div class="text-muted small mt-1">
                            <i class="fas fa-calendar-alt me-1"></i>
                            {{ $prediction->created_at->format('d M Y, H:i') }} &nbsp;|&nbsp;
                            <b>HPL:</b> {{ $hpl }}
                        </div>
                    </div>

                    <!-- Info Faktor dan Confidence -->
                    <div class="px-4 pt-4">
                        <div class="row justify-content-center text-center">
                            <div class="col-12 col-md-6 mb-2">
                                <div class="rounded-3 px-3 py-2 bg-light">
                                    <span class="fw-semibold text-secondary">Faktor Penentu:</span>
                                    <br>
                                    <span class="fw-normal">{{ $prediction->faktor ?? 'Tidak tersedia' }}</span>
                                </div>
                            </div>
                            <div class="col-12 col-md-6 mb-2">
                                <div class="rounded-3 px-3 py-2 bg-light">
                                    <span class="fw-semibold text-secondary">Confidence:</span>
                                    <br>
                                    <span class="fw-normal">{{ is_numeric($prediction->confidence) ? round($prediction->confidence) . '%' : '-' }}</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Konten Detail -->
                    <div class="px-4 pb-3 pt-4">
                        <div class="row g-4">
                            <div class="col-md-6">
                                <div class="mb-2">
                                    <span class="fw-semibold text-secondary">Nama Ibu:</span>
                                    <span class="fw-normal">{{ $prediction->user->name ?? '-' }}</span>
                                </div>
                                <div class="mb-2">
                                    <span class="fw-semibold text-secondary">Usia Ibu:</span>
                                    <span class="fw-normal">{{ $prediction->usia_ibu }} tahun</span>
                                </div>
                                <div class="mb-2">
                                    <span class="fw-semibold text-secondary">Tekanan Darah:</span>
                                    <span class="fw-normal">{{ ucfirst($prediction->tekanan_darah) }}</span>
                                </div>
                                <div class="mb-2">
                                    <span class="fw-semibold text-secondary">Riwayat Persalinan:</span>
                                    <span class="fw-normal">{{ ucfirst($prediction->riwayat_persalinan) }}</span>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-2">
                                    <span class="fw-semibold text-secondary">Posisi Janin:</span>
                                    <span class="fw-normal">{{ ucfirst($prediction->posisi_janin) }}</span>
                                </div>
                                <div class="mb-2">
                                    <span class="fw-semibold text-secondary">Kondisi Janin:</span>
                                    <span class="fw-normal">{{ ucfirst($prediction->kondisi_kesehatan_janin) }}</span>
                                </div>
                                <div class="mb-2">
                                    <span class="fw-semibold text-secondary">Riwayat Kesehatan Ibu:</span>
                                    <span class="fw-normal">{{ ucfirst($prediction->riwayat_kesehatan_ibu) }}</span>
                                </div>
                                <div class="mb-2 d-md-none">
                                    <span class="fw-semibold text-secondary">HPL:</span>
                                    <span class="fw-normal">{{ $hpl }}</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Tombol Aksi -->
                    <div class="px-4 pb-4 pt-3 d-flex flex-column flex-md-row justify-content-between align-items-center gap-2" style="background: #fff; border-radius: 0 0 18px 18px;">
                        <a href="{{ route('prediksi.index') }}"
                           class="btn btn-outline-primary fw-semibold px-4 py-2 rounded-3">
                            <i class="fas fa-list me-1"></i> Kembali ke Riwayat
                        </a>
                        @if(Route::has('prediksi.print'))
                        <a href="{{ route('prediksi.print', $prediction->id) }}" target="_blank"
                           class="btn fw-semibold px-4 py-2 rounded-3"
                           style="background: linear-gradient(45deg, #4dbaff, #1a87e3); color: white;">
                            <i class="fas fa-print me-1"></i> Cetak Hasil
                        </a>
                        @endif
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>

<!-- Custom Styles -->
<style>
    .btn, .card, .alert { transition: all 0.3s; }
    .btn-outline-primary:hover {
        background: linear-gradient(45deg, #4dbaff, #1a87e3) !important;
        color: white !important;
        border: none !important;
    }
    .badge {
        letter-spacing: 1px;
        font-size: 1.12rem;
    }
</style>
@endsection
