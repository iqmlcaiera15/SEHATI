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

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-8 col-md-10">
            <div class="card border-0 shadow-lg rounded-4 overflow-hidden position-relative"
                 style="background: linear-gradient(110deg, #F6F9FF 70%, #e8f0ff 100%);">
                <!-- Badge Prediksi -->
                <div class="text-center pt-5 pb-1" style="background: #fff;">
                    <span class="badge px-4 py-2 fw-bold rounded-pill border {{ $badgeClass }}" style="font-size: 1.15rem; box-shadow: 0 2px 12px rgba(34,139,230,0.07); letter-spacing: 1px;">
                        {{ ucfirst($prediction->metode_persalinan) }}
                    </span>
                </div>
                <div class="text-center px-4 pb-1 pt-1" style="background: #fff;">
                    <h2 class="fw-bold mb-2 text-dark" style="letter-spacing: 0.5px;">
                        Hasil Prediksi Persalinan
                    </h2>
                    <div class="small text-muted mb-2">
                        {{ $prediction->created_at->format('d M Y, H:i') }}
                        &nbsp;|&nbsp;
                        <b>HPL:</b> {{ $hpl }}
                    </div>
                    <div class="mb-2">
                        <span class="fw-semibold text-secondary">Faktor Penentu:</span>
                        <span class="fw-normal">{{ $prediction->faktor ?? 'Tidak tersedia' }}</span>
                    </div>
                    <div class="mb-2">
                        <span class="fw-semibold text-secondary">Confidence:</span>
                        <span class="fw-normal">{{ is_numeric($prediction->confidence) ? round($prediction->confidence) . '%' : '-' }}</span>
                    </div>
                </div>
                <!-- Konten Detail -->
                <div class="card-body p-4 pb-0">
                    <div class="row g-4">
                        <div class="col-md-6">
                            <div class="mb-3">
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
                <div class="px-4 pb-4 pt-3 d-flex flex-column flex-md-row justify-content-between align-items-center gap-2" style="background: #fff;">
                    <a href="{{ route('prediksi.index') }}" class="btn btn-light border fw-semibold px-4">
                        Kembali ke Riwayat
                    </a>
                    @if(Route::has('prediksi.print'))
                    <a href="{{ route('prediksi.print', $prediction->id) }}" target="_blank" class="btn btn-primary fw-semibold px-4">
                        Cetak Hasil
                    </a>
                    @endif
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
