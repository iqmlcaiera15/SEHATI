@extends('layouts.app')

@section('content')
@php
    $method = strtolower($prediction->metode_persalinan);
    $isCaesar = $method === 'caesar';
    $badgeClass = $isCaesar ? 'bg-danger bg-opacity-10 text-danger border-danger' : 'bg-primary bg-opacity-10 text-primary border-primary';
    $icon = $isCaesar ? 'fa-scissors' : 'fa-baby';
    $hpl = $prediction->hpl && $prediction->hpl->hpl
        ? \Carbon\Carbon::parse($prediction->hpl->hpl)->translatedFormat('d F Y')
        : '-';
@endphp

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-8 col-md-10">
            <div class="card border-0 shadow-lg rounded-4 overflow-hidden position-relative"
                 style="background: linear-gradient(110deg, #F6F9FF 70%, #e8f0ff 100%);">
                <!-- Badge Prediksi -->
                <div class="text-center pt-5 pb-1" style="background: #fff;">
                    <span class="badge px-4 py-2 fw-bold rounded-pill border {{ $badgeClass }}" style="font-size: 1.15rem; box-shadow: 0 2px 12px rgba(34,139,230,0.07); letter-spacing: 1px;">
                        <i class="fas {{ $icon }} me-2"></i>
                        {{ ucfirst($prediction->metode_persalinan) }}
                    </span>
                </div>
                <div class="text-center px-4 pb-1 pt-1" style="background: #fff;">
                    <h2 class="fw-bold mb-2 text-dark" style="letter-spacing: 0.5px;">
                        Hasil Prediksi Persalinan
                    </h2>
                    <div class="small text-muted mb-2">
                        <i class="fas fa-calendar-alt me-1"></i>
                        {{ $prediction->created_at->format('d M Y, H:i') }}
                        &nbsp;|&nbsp;
                        <i class="fas fa-calendar me-1"></i>
                        <b>HPL:</b> {{ $hpl }}
                    </div>
                    <span class="text-secondary fw-semibold d-block mb-2">
                        <i class="fas fa-lightbulb me-1 text-warning"></i>
                        Faktor Penentu:
                        {{ is_array($prediction->faktor) ? implode(', ', $prediction->faktor) : ($prediction->faktor ?? 'Tidak tersedia') }}
                    </span>
                </div>
                <!-- Konten Detail -->
                <div class="card-body p-4 pb-0">
                    <div class="row g-4">
                        <div class="col-md-6">
                            <div class="d-flex align-items-center mb-3">
                                <div class="icon-box bg-primary bg-opacity-10 text-primary me-2">
                                    <i class="fas fa-user-circle fa-lg"></i>
                                </div>
                                <span class="fw-semibold">Nama Ibu:</span>&nbsp; {{ $prediction->user->name ?? '-' }}
                            </div>
                            <div class="d-flex align-items-center mb-2">
                                <div class="icon-box bg-warning bg-opacity-10 text-warning me-2">
                                    <i class="fas fa-birthday-cake fa-lg"></i>
                                </div>
                                <span class="fw-semibold">Usia Ibu:</span>&nbsp; {{ $prediction->usia_ibu }} tahun
                            </div>
                            <div class="d-flex align-items-center mb-2">
                                <div class="icon-box bg-info bg-opacity-10 text-info me-2">
                                    <i class="fas fa-tachometer-alt fa-lg"></i>
                                </div>
                                <span class="fw-semibold">Tekanan Darah:</span>&nbsp; {{ ucfirst($prediction->tekanan_darah) }}
                            </div>
                            <div class="d-flex align-items-center mb-2">
                                <div class="icon-box bg-success bg-opacity-10 text-success me-2">
                                    <i class="fas fa-history fa-lg"></i>
                                </div>
                                <span class="fw-semibold">Riwayat Persalinan:</span>&nbsp; {{ ucfirst($prediction->riwayat_persalinan) }}
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="d-flex align-items-center mb-2">
                                <div class="icon-box bg-danger bg-opacity-10 text-danger me-2">
                                    <i class="fas fa-baby-carriage fa-lg"></i>
                                </div>
                                <span class="fw-semibold">Posisi Janin:</span>&nbsp; {{ ucfirst($prediction->posisi_janin) }}
                            </div>
                            <div class="d-flex align-items-center mb-2">
                                <div class="icon-box bg-pink bg-opacity-10 text-pink me-2">
                                    <i class="fas fa-heartbeat fa-lg"></i>
                                </div>
                                <span class="fw-semibold">Kondisi Janin:</span>&nbsp; {{ ucfirst($prediction->kondisi_kesehatan_janin) }}
                            </div>
                            <div class="d-flex align-items-center mb-2">
                                <div class="icon-box bg-secondary bg-opacity-10 text-secondary me-2">
                                    <i class="fas fa-notes-medical fa-lg"></i>
                                </div>
                                <span class="fw-semibold">Riwayat Kesehatan Ibu:</span>&nbsp; {{ ucfirst($prediction->riwayat_kesehatan_ibu) }}
                            </div>
                            <div class="d-flex align-items-center mb-2 d-md-none">
                                <div class="icon-box bg-info bg-opacity-10 text-info me-2">
                                    <i class="fas fa-calendar fa-lg"></i>
                                </div>
                                <span class="fw-semibold">HPL:</span>&nbsp; {{ $hpl }}
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Tombol Aksi -->
                <div class="px-4 pb-4 pt-3 d-flex flex-column flex-md-row justify-content-between align-items-center gap-2" style="background: #fff;">
                    <a href="{{ route('prediksi.index') }}" class="btn btn-light border fw-semibold px-4">
                        <i class="fas fa-arrow-left me-1"></i> Kembali ke Riwayat
                    </a>
                    @if(Route::has('prediksi.print'))
                    <a href="{{ route('prediksi.print', $prediction->id) }}" target="_blank" class="btn btn-primary fw-semibold px-4">
                        <i class="fas fa-print me-1"></i> Cetak Hasil
                    </a>
                    @endif
                </div>
            </div>
        </div>
    </div>
</div>
<!-- Tambahan style untuk icon box agar modern dan konsisten -->
<style>
    .icon-box {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 38px;
        height: 38px;
        border-radius: 50%;
        font-size: 1.35rem;
        box-shadow: 0 1px 5px rgba(0, 0, 0, 0.05);
    }
    /* Pink support untuk heartbeat */
    .text-pink { color: #e83e8c !important; }
    .bg-pink { background-color: #fce4ec !important; }
</style>
@endsection
