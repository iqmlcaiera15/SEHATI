@extends('layouts.app')

@section('content')
@php
    $method = strtolower($prediction->metode_persalinan);
    $isCaesar = $method === 'caesar';
    // Warna headline dan oval pakai class Bootstrap (text-primary / text-danger)
    $headlineClass = $isCaesar ? 'text-danger' : 'text-primary';
    $ovalClass     = $isCaesar ? 'border-danger text-danger' : 'border-primary text-primary';
    $hpl = $prediction->hpl && $prediction->hpl->hpl
        ? \Carbon\Carbon::parse($prediction->hpl->hpl)->translatedFormat('d F Y')
        : '-';
@endphp

<div class="container-fluid py-4">
    <!-- Header Section -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="card border-0 shadow-sm" style="background: linear-gradient(135deg, #4dbaff 0%, #1a87e3 100%); border-radius: 15px;">
                <div class="card-body text-white d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-2">
                            <i class="fas fa-baby me-2"></i>
                            Hasil Prediksi Persalinan
                        </h2>
                        <span class="opacity-75">Lihat hasil prediksi dan saran berdasarkan data ibu.</span>
                    </div>
                    <a href="{{ route('prediksi.index') }}" class="btn btn-light d-flex align-items-center shadow-sm px-4 rounded-3 fw-semibold" style="background: #fff; color: #1976d2; border: none;">
                        <i class="fas fa-arrow-left me-2"></i> Riwayat
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Card Hasil Prediksi -->
    <div class="row justify-content-center">
        <div class="col-lg-8 col-md-10">
            <div class="card border-0 shadow-lg rounded-4 overflow-hidden" style="background: linear-gradient(120deg, #f8fbff 75%, #e4f1fe 100%); border-radius: 20px;">
                <div class="card-body p-0">

                    <!-- Ilustrasi, HEADLINE HASIL, info waktu -->
                    <div class="d-flex flex-column align-items-center justify-content-center pt-4 pb-3" style="background: #fff; border-radius: 20px 20px 0 0;">
                        <div class="mb-3">
                            <i class="fas fa-stethoscope" style="font-size: 3rem; color: #4dbaff;"></i>
                        </div>
                        <!-- HEADLINE DAN OVAL HASIL -->
                        <div class="d-flex flex-column align-items-center mb-2">
                            <div class="fw-bold {{ $headlineClass }}" style="font-size:2.5rem;letter-spacing:1.5px;margin-bottom:8px;">
                                {{ $isCaesar ? 'Caesar' : 'Normal' }}
                            </div>
                            <div class="border {{ $ovalClass }} rounded-pill px-4 py-2 fw-bold" style="font-size:1.15rem; border-width:2px;">
                                {{ ucfirst($prediction->metode_persalinan) }}
                            </div>
                        </div>
                        <div class="text-muted small mt-2 mb-2">
                            <i class="fas fa-calendar-alt me-1"></i>
                            {{ $prediction->created_at->format('d M Y, H:i') }} &nbsp;|&nbsp;
                            <b>HPL:</b> {{ $hpl }}
                        </div>
                    </div>

                    <!-- Info Faktor dan Confidence -->
                    <div class="row g-3 justify-content-center px-4 pt-4 pb-0">
                        <div class="col-12 col-md-6 mb-2">
                            <div class="rounded-4 px-3 py-3 bg-white border h-100 d-flex flex-column align-items-center">
                                <span class="fw-semibold text-secondary mb-1"><i class="fas fa-lightbulb me-1"></i> Faktor Penentu</span>
                                <span class="fw-normal" style="font-size: 1.08rem;">{{ $prediction->faktor ?? 'Tidak tersedia' }}</span>
                            </div>
                        </div>
                        <div class="col-12 col-md-6 mb-2">
                            <div class="rounded-4 px-3 py-3 bg-white border h-100 d-flex flex-column align-items-center">
                                <span class="fw-semibold text-secondary mb-1"><i class="fas fa-percentage me-1"></i> Confidence</span>
                                <span class="fw-normal" style="font-size: 1.19rem;">{{ is_numeric($prediction->confidence) ? round($prediction->confidence) . '%' : '-' }}</span>
                            </div>
                        </div>
                    </div>

                    <!-- Konten Detail Data -->
                    <div class="px-4 py-4">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <div class="rounded-3 border bg-light px-3 py-2 mb-2 d-flex align-items-center gap-2">
                                    <i class="fas fa-user text-primary"></i>
                                    <span><b>Nama Ibu:</b> {{ $prediction->user->name ?? '-' }}</span>
                                </div>
                                <div class="rounded-3 border bg-light px-3 py-2 mb-2 d-flex align-items-center gap-2">
                                    <i class="fas fa-hourglass-half text-primary"></i>
                                    <span><b>Usia Ibu:</b> {{ $prediction->usia_ibu }} tahun</span>
                                </div>
                                <div class="rounded-3 border bg-light px-3 py-2 mb-2 d-flex align-items-center gap-2">
                                    <i class="fas fa-tint text-primary"></i>
                                    <span><b>Tekanan Darah:</b> {{ ucfirst($prediction->tekanan_darah) }}</span>
                                </div>
                                <div class="rounded-3 border bg-light px-3 py-2 d-flex align-items-center gap-2">
                                    <i class="fas fa-history text-primary"></i>
                                    <span><b>Riwayat Persalinan:</b> {{ ucfirst($prediction->riwayat_persalinan) }}</span>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="rounded-3 border bg-light px-3 py-2 mb-2 d-flex align-items-center gap-2">
                                    <i class="fas fa-baby text-primary"></i>
                                    <span><b>Posisi Janin:</b> {{ ucfirst($prediction->posisi_janin) }}</span>
                                </div>
                                <div class="rounded-3 border bg-light px-3 py-2 mb-2 d-flex align-items-center gap-2">
                                    <i class="fas fa-heartbeat text-primary"></i>
                                    <span><b>Kondisi Janin:</b> {{ ucfirst($prediction->kondisi_kesehatan_janin) }}</span>
                                </div>
                                <div class="rounded-3 border bg-light px-3 py-2 mb-2 d-flex align-items-center gap-2">
                                    <i class="fas fa-notes-medical text-primary"></i>
                                    <span><b>Riwayat Kesehatan Ibu:</b> {{ ucfirst($prediction->riwayat_kesehatan_ibu) }}</span>
                                </div>
                                <div class="rounded-3 border bg-light px-3 py-2 d-flex align-items-center gap-2 d-md-none">
                                    <i class="fas fa-calendar text-primary"></i>
                                    <span><b>HPL:</b> {{ $hpl }}</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Tombol Aksi -->
                    <div class="px-4 pb-4 pt-3 d-flex flex-column flex-md-row justify-content-between align-items-center gap-2" style="background: #fff; border-radius: 0 0 20px 20px;">
                        <a href="{{ route('prediksi.index') }}"
                           class="btn btn-light fw-semibold px-4 py-2 rounded-3 d-flex align-items-center gap-2 border"
                           style="background: #fff; color: #1976d2; border: 1.5px solid #d7e4ef;">
                            <i class="fas fa-list"></i> Kembali ke Riwayat
                        </a>
                        @if(Route::has('prediksi.print'))
                        <a href="{{ route('prediksi.print', $prediction->id) }}" target="_blank"
                           class="btn fw-semibold px-4 py-2 rounded-3 d-flex align-items-center gap-2"
                           style="background: linear-gradient(45deg, #4dbaff, #1a87e3); color: white;">
                            <i class="fas fa-print"></i> Cetak Hasil
                        </a>
                        @endif
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>
@endsection
