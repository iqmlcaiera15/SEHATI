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
                            <span class="opacity-75">Lihat hasil prediksi dan saran berdasarkan data ibu.</span>
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
            <div class="card border-0 shadow-lg rounded-4 overflow-hidden" style="background: linear-gradient(120deg, #f8fbff 75%, #e4f1fe 100%); border-radius: 20px;">
                <div class="card-body p-0">

                    <!-- Ilustrasi dan Badge Prediksi -->
                    <div class="d-flex flex-column align-items-center justify-content-center py-4" style="background: #fff; border-radius: 20px 20px 0 0;">
                        <div class="mb-2">
                            <i class="fas fa-stethoscope" style="font-size: 2.5rem; color: #4dbaff;"></i>
                        </div>
                        <span class="badge px-4 py-2 fw-bold rounded-pill border {{ $badgeClass }}" style="font-size: 1.25rem; box-shadow: 0 2px 14px rgba(34,139,230,0.07); letter-spacing: 1px;">
                            {{ ucfirst($prediction->metode_persalinan) }}
                        </span>
                        <div class="fw-bold mt-3" style="font-size: 2.2rem; color: #205685; letter-spacing: 0.5px;">
                            {{ $isCaesar ? 'Caesar' : 'Normal' }}
                        </div>
                        <div class="text-muted small mt-2">
                            <i class="fas fa-calendar-alt me-1"></i>
                            {{ $prediction->created_at->format('d M Y, H:i') }} &nbsp;|&nbsp;
                            <b>HPL:</b> {{ $hpl }}
                        </div>
                    </div>

                    <!-- Info Faktor dan Confidence -->
                    <div class="row g-3 justify-content-center px-4 pt-4 pb-0">
                        <div class="col-12 col-md-6 mb-2">
                            <div class="rounded-4 px-3 py-3 bg-white border shadow-sm h-100 d-flex flex-column align-items-center">
                                <span class="fw-semibold text-secondary mb-1"><i class="fas fa-lightbulb me-1"></i> Faktor Penentu</span>
                                <span class="fw-normal" style="font-size: 1.1rem;">{{ $prediction->faktor ?? 'Tidak tersedia' }}</span>
                            </div>
                        </div>
                        <div class="col-12 col-md-6 mb-2">
                            <div class="rounded-4 px-3 py-3 bg-white border shadow-sm h-100 d-flex flex-column align-items-center">
                                <span class="fw-semibold text-secondary mb-1"><i class="fas fa-percentage me-1"></i> Confidence</span>
                                <span class="fw-normal" style="font-size: 1.25rem;">{{ is_numeric($prediction->confidence) ? round($prediction->confidence) . '%' : '-' }}</span>
                            </div>
                        </div>
                    </div>

                    <!-- Konten Detail Data -->
                    <div class="px-4 py-4">
                        <div class="row g-4">
                            <div class="col-md-6">
                                <div class="rounded-3 border bg-light px-3 py-2 mb-2 shadow-xs">
                                    <span class="fw-semibold text-secondary"><i class="fas fa-user me-1"></i> Nama Ibu:</span>
                                    <span class="fw-normal">{{ $prediction->user->name ?? '-' }}</span>
                                </div>
                                <div class="rounded-3 border bg-light px-3 py-2 mb-2 shadow-xs">
                                    <span class="fw-semibold text-secondary"><i class="fas fa-hourglass-half me-1"></i> Usia Ibu:</span>
                                    <span class="fw-normal">{{ $prediction->usia_ibu }} tahun</span>
                                </div>
                                <div class="rounded-3 border bg-light px-3 py-2 mb-2 shadow-xs">
                                    <span class="fw-semibold text-secondary"><i class="fas fa-tint me-1"></i> Tekanan Darah:</span>
                                    <span class="fw-normal">{{ ucfirst($prediction->tekanan_darah) }}</span>
                                </div>
                                <div class="rounded-3 border bg-light px-3 py-2 shadow-xs">
                                    <span class="fw-semibold text-secondary"><i class="fas fa-history me-1"></i> Riwayat Persalinan:</span>
                                    <span class="fw-normal">{{ ucfirst($prediction->riwayat_persalinan) }}</span>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="rounded-3 border bg-light px-3 py-2 mb-2 shadow-xs">
                                    <span class="fw-semibold text-secondary"><i class="fas fa-baby me-1"></i> Posisi Janin:</span>
                                    <span class="fw-normal">{{ ucfirst($prediction->posisi_janin) }}</span>
                                </div>
                                <div class="rounded-3 border bg-light px-3 py-2 mb-2 shadow-xs">
                                    <span class="fw-semibold text-secondary"><i class="fas fa-heartbeat me-1"></i> Kondisi Janin:</span>
                                    <span class="fw-normal">{{ ucfirst($prediction->kondisi_kesehatan_janin) }}</span>
                                </div>
                                <div class="rounded-3 border bg-light px-3 py-2 mb-2 shadow-xs">
                                    <span class="fw-semibold text-secondary"><i class="fas fa-notes-medical me-1"></i> Riwayat Kesehatan Ibu:</span>
                                    <span class="fw-normal">{{ ucfirst($prediction->riwayat_kesehatan_ibu) }}</span>
                                </div>
                                <div class="rounded-3 border bg-light px-3 py-2 shadow-xs d-md-none">
                                    <span class="fw-semibold text-secondary"><i class="fas fa-calendar me-1"></i> HPL:</span>
                                    <span class="fw-normal">{{ $hpl }}</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Tombol Aksi -->
                    <div class="px-4 pb-4 pt-3 d-flex flex-column flex-md-row justify-content-between align-items-center gap-2" style="background: #fff; border-radius: 0 0 20px 20px;">
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
        font-size: 1.17rem;
    }
    .shadow-xs {
        box-shadow: 0 1px 8px rgba(34,139,230,0.07) !important;
    }
</style>
@endsection
