@extends('layouts.app')

@section('content')
@php
    $method = strtolower($prediction->metode_persalinan);
    $isCaesar = $method === 'caesar';
    $methodColor = $isCaesar ? 'text-danger' : 'text-success';
    $badgeColor = $isCaesar ? 'bg-danger-subtle text-danger' : 'bg-success-subtle text-success';
    $icon = $isCaesar ? 'fa-procedures' : 'fa-baby';
@endphp

<div class="container py-4">
    <h3 class="mb-4 fw-semibold text-primary">
        <i class="fas fa-heartbeat me-2"></i> Hasil Prediksi Metode Persalinan
    </h3>

    <div class="card shadow-sm border-0 bg-light">
        <div class="card-body">
            <div class="text-center mb-4">
                <h4 class="fw-bold {{ $methodColor }}">
                    <i class="fas {{ $icon }} me-2"></i> {{ ucfirst($prediction->metode_persalinan) }}
                </h4>
                <span class="badge {{ $badgeColor }} px-3 py-2">
                    Faktor Penentu: {{ is_array($prediction->faktor) ? implode(', ', $prediction->faktor) : ($prediction->faktor ?? 'Tidak tersedia') }}
                </span>
                <div class="mt-2 text-muted">
                    <i class="fas fa-calendar-alt me-1"></i>
                    Prediksi dilakukan pada {{ $prediction->created_at->format('d M Y, H:i') }}
                </div>
            </div>
            <hr>

            <div class="row g-4">
                <div class="col-md-6">
                    <p><strong><i class="fas fa-user me-1 text-muted"></i> Nama Ibu:</strong> {{ $prediction->user->name ?? '-' }}</p>
                    <p><strong><i class="fas fa-birthday-cake me-1 text-muted"></i> Usia Ibu:</strong> {{ $prediction->usia_ibu }} tahun</p>
                    <p><strong><i class="fas fa-tachometer-alt me-1 text-muted"></i> Tekanan Darah:</strong> {{ ucfirst($prediction->tekanan_darah) }}</p>
                    <p><strong><i class="fas fa-history me-1 text-muted"></i> Riwayat Persalinan:</strong> {{ ucfirst($prediction->riwayat_persalinan) }}</p>
                </div>
                <div class="col-md-6">
                    <p><strong><i class="fas fa-baby-carriage me-1 text-muted"></i> Posisi Janin:</strong> {{ ucfirst($prediction->posisi_janin) }}</p>
                    <p><strong><i class="fas fa-heart me-1 text-muted"></i> Kondisi Kesehatan Janin:</strong> {{ ucfirst($prediction->kondisi_kesehatan_janin) }}</p>
                    <p><strong><i class="fas fa-notes-medical me-1 text-muted"></i> Riwayat Kesehatan Ibu:</strong> {{ ucfirst($prediction->riwayat_kesehatan_ibu) }}</p>
                </div>
            </div>
            <div class="mt-4 d-flex justify-content-between">
                <a href="{{ route('prediksi.index') }}" class="btn btn-outline-secondary">
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
@endsection
