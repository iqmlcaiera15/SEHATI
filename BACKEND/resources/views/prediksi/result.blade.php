@extends('layouts.app')

@section('content')
@php
    $method = strtolower($prediction->metode_persalinan);
    $isCaesar = $method === 'caesar';
    $methodColor = $isCaesar ? 'text-danger' : 'text-primary';
    $badgeColor = $isCaesar ? 'bg-danger bg-opacity-10 text-danger border-danger' : 'bg-primary bg-opacity-10 text-primary border-primary';
    $icon = $isCaesar ? 'fa-scissors' : 'fa-baby';
    $hpl = $prediction->hpl && $prediction->hpl->hpl
        ? \Carbon\Carbon::parse($prediction->hpl->hpl)->translatedFormat('d F Y')
        : '-';
@endphp

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-8 col-md-10">

            <div class="card border-0 shadow-lg rounded-4 position-relative p-0 overflow-hidden" style="background: linear-gradient(105deg, #F6F9FF 75%, #f1f5ff 100%);">
                <div class="p-4 pb-0 text-center" style="background: #fff; border-bottom: 1px solid #ececec;">
                    <span class="badge px-4 py-2 fw-bold mb-3 rounded-pill border {{ $badgeColor }}" style="font-size: 1.1rem;">
                        <i class="fas {{ $icon }} me-2"></i>
                        {{ ucfirst($prediction->metode_persalinan) }}
                    </span>
                    <h2 class="fw-bold mb-1 text-dark" style="letter-spacing: 1px;">
                        Hasil Prediksi Metode Persalinan
                    </h2>
                    <div class="small text-muted">
                        <i class="fas fa-calendar-alt me-1"></i>
                        {{ $prediction->created_at->format('d M Y, H:i') }}
                        &nbsp;|&nbsp;
                        <i class="fas fa-calendar me-1"></i>
                        <b>HPL:</b> {{ $hpl }}
                    </div>
                    <div class="mt-3 mb-0">
                        <span class="text-secondary fw-semibold">
                            <i class="fas fa-lightbulb me-1 text-warning"></i>
                            Faktor Penentu:
                            {{ is_array($prediction->faktor) ? implode(', ', $prediction->faktor) : ($prediction->faktor ?? 'Tidak tersedia') }}
                        </span>
                    </div>
                </div>

                <div class="card-body px-4 pt-4 pb-2">
                    <div class="row g-4">
                        <div class="col-md-6">
                            <div class="d-flex align-items-center mb-3">
                                <i class="fas fa-user-circle fa-lg me-2 text-primary"></i>
                                <span class="fw-semibold">Nama Ibu:</span>&nbsp; {{ $prediction->user->name ?? '-' }}
                            </div>
                            <div class="d-flex align-items-center mb-2">
                                <i class="fas fa-birthday-cake fa-lg me-2 text-warning"></i>
                                <span class="fw-semibold">Usia Ibu:</span>&nbsp; {{ $prediction->usia_ibu }} tahun
                            </div>
                            <div class="d-flex align-items-center mb-2">
                                <i class="fas fa-tachometer-alt fa-lg me-2 text-info"></i>
                                <span class="fw-semibold">Tekanan Darah:</span>&nbsp; {{ ucfirst($prediction->tekanan_darah) }}
                            </div>
                            <div class="d-flex align-items-center mb-2">
                                <i class="fas fa-history fa-lg me-2 text-success"></i>
                                <span class="fw-semibold">Riwayat Persalinan:</span>&nbsp; {{ ucfirst($prediction->riwayat_persalinan) }}
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="d-flex align-items-center mb-2">
                                <i class="fas fa-baby-carriage fa-lg me-2 text-danger"></i>
                                <span class="fw-semibold">Posisi Janin:</span>&nbsp; {{ ucfirst($prediction->posisi_janin) }}
                            </div>
                            <div class="d-flex align-items-center mb-2">
                                <i class="fas fa-heartbeat fa-lg me-2 text-pink"></i>
                                <span class="fw-semibold">Kondisi Janin:</span>&nbsp; {{ ucfirst($prediction->kondisi_kesehatan_janin) }}
                            </div>
                            <div class="d-flex align-items-center mb-2">
                                <i class="fas fa-notes-medical fa-lg me-2 text-secondary"></i>
                                <span class="fw-semibold">Riwayat Kesehatan Ibu:</span>&nbsp; {{ ucfirst($prediction->riwayat_kesehatan_ibu) }}
                            </div>
                            <div class="d-flex align-items-center mb-2 d-md-none">
                                <i class="fas fa-calendar fa-lg me-2 text-info"></i>
                                <span class="fw-semibold">HPL:</span>&nbsp; {{ $hpl }}
                            </div>
                        </div>
                    </div>
                </div>

                <div class="px-4 pb-4 d-flex flex-column flex-md-row justify-content-between align-items-center">
                    <a href="{{ route('prediksi.index') }}" class="btn btn-outline-secondary mb-2 mb-md-0">
                        <i class="fas fa-arrow-left me-1"></i> Kembali ke Riwayat
                    </a>
                    @if(Route::has('prediksi.print'))
                    <a href="{{ route('prediksi.print', $prediction->id) }}" target="_blank" class="btn btn-outline-primary">
                        <i class="fas fa-print me-1"></i> Cetak Hasil
                    </a>
                    @endif
                </div>
            </div>

        </div>
    </div>
</div>
@endsection
