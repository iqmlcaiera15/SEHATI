@extends('layouts.app')

@section('content')
@php
    $method = strtolower($prediction->metode_persalinan);
    $isCaesar = $method === 'caesar';
    $methodColor = $isCaesar ? 'text-danger' : 'text-success';
    $badgeColor = $isCaesar ? 'bg-danger-subtle text-danger' : 'bg-success-subtle text-success';
    $icon = $isCaesar ? 'fa-procedures' : 'fa-baby';
    $hpl = $prediction->hpl && $prediction->hpl->hpl
        ? \Carbon\Carbon::parse($prediction->hpl->hpl)->format('d F Y')
        : '-';
@endphp

<div class="container py-4">
    <div class="row justify-content-center">
        <div class="col-lg-8 col-md-10">
            <div class="card border-0 shadow rounded-4 bg-light position-relative">
                <div class="card-body px-4 py-5">
                    <div class="text-center mb-4">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <span class="badge {{ $badgeColor }} fs-6 px-3 py-2 mb-2">
                                    {{ ucfirst($prediction->metode_persalinan) }}
                                </span>
                                <h3 class="fw-bold {{ $methodColor }} mb-0">
                                    <i class="fas {{ $icon }} me-2"></i>
                                    Hasil Prediksi Metode Persalinan
                                </h3>
                            </div>
                            <div class="text-end d-none d-md-block">
                                <div class="text-muted small">
                                    <i class="fas fa-calendar-alt me-1"></i>
                                    Prediksi: {{ $prediction->created_at->format('d M Y, H:i') }}
                                </div>
                                <div class="mt-2">
                                    <span class="badge bg-info-subtle text-info fw-semibold">
                                        HPL: <i class="fas fa-calendar me-1"></i> {{ $hpl }}
                                    </span>
                                </div>
                            </div>
                        </div>
                        <div class="d-block d-md-none mt-3 mb-2">
                            <span class="badge bg-info-subtle text-info fw-semibold">
                                <i class="fas fa-calendar me-1"></i> HPL: {{ $hpl }}
                            </span>
                        </div>
                        <div class="mt-3">
                            <span class="text-secondary">
                                <strong>Faktor Penentu:</strong>
                                {{ is_array($prediction->faktor) ? implode(', ', $prediction->faktor) : ($prediction->faktor ?? 'Tidak tersedia') }}
                            </span>
                        </div>
                    </div>
                    <hr>
                    <div class="row g-4 mb-2">
                        <div class="col-md-6">
                            <div class="mb-2"><i class="fas fa-user text-primary me-2"></i><strong>Nama Ibu:</strong> {{ $prediction->user->name ?? '-' }}</div>
                            <div class="mb-2"><i class="fas fa-birthday-cake text-warning me-2"></i><strong>Usia Ibu:</strong> {{ $prediction->usia_ibu }} tahun</div>
                            <div class="mb-2"><i class="fas fa-tachometer-alt text-info me-2"></i><strong>Tekanan Darah:</strong> {{ ucfirst($prediction->tekanan_darah) }}</div>
                            <div class="mb-2"><i class="fas fa-history text-success me-2"></i><strong>Riwayat Persalinan:</strong> {{ ucfirst($prediction->riwayat_persalinan) }}</div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-2"><i class="fas fa-baby-carriage text-danger me-2"></i><strong>Posisi Janin:</strong> {{ ucfirst($prediction->posisi_janin) }}</div>
                            <div class="mb-2"><i class="fas fa-heart text-pink me-2"></i><strong>Kondisi Kesehatan Janin:</strong> {{ ucfirst($prediction->kondisi_kesehatan_janin) }}</div>
                            <div class="mb-2"><i class="fas fa-notes-medical text-secondary me-2"></i><strong>Riwayat Kesehatan Ibu:</strong> {{ ucfirst($prediction->riwayat_kesehatan_ibu) }}</div>
                            <div class="mb-2 d-md-none"><i class="fas fa-calendar text-info me-2"></i><strong>HPL:</strong> {{ $hpl }}</div>
                        </div>
                    </div>
                    <hr>
                    <div class="mt-4 d-flex flex-column flex-md-row justify-content-between align-items-center">
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
</div>
@endsection
