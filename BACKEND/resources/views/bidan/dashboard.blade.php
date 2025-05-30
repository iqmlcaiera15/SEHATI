@extends('layouts.app')

@section('content')
<div class="container-fluid px-4">
    <h1 class="mt-4">Dashboard Bidan</h1>
    <ol class="breadcrumb mb-4">
        <li class="breadcrumb-item active">Dashboard</li>
    </ol>

    <!-- Summary Cards Row -->
    <div class="row mb-4">
        <div class="col-xl-3 col-md-6">
            <div class="card bg-primary text-white mb-4">
                <div class="card-body">
                    <h4>{{ $ibuHamil->count() }}</h4>
                    Total Ibu Hamil
                </div>
                <div class="card-footer d-flex align-items-center justify-content-between">
                    <a class="small text-white stretched-link" href="#">Lihat Detail</a>
                    <div class="small text-white"><i class="fas fa-angle-right"></i></div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6">
            <div class="card bg-warning text-white mb-4">
                <div class="card-body">
                    <h4>{{ $deteksiPenyakit->count() }}</h4>
                    Total Deteksi Penyakit
                </div>
                <div class="card-footer d-flex align-items-center justify-content-between">
                    <a class="small text-white stretched-link" href="{{ route('deteksi.index') }}">Lihat Detail</a>
                    <div class="small text-white"><i class="fas fa-angle-right"></i></div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6">
            <div class="card bg-success text-white mb-4">
                <div class="card-body">
                    <h4>{{ $prediksiDepresi->count() }}</h4>
                    Total Prediksi Depresi
                </div>
                <div class="card-footer d-flex align-items-center justify-content-between">
                    <a class="small text-white stretched-link" href="{{ route('depresi.index') }}">Lihat Detail</a>
                    <div class="small text-white"><i class="fas fa-angle-right"></i></div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6">
            <div class="card bg-danger text-white mb-4">
                <div class="card-body">
                    <h4>{{ $prediksiJanin->count() }}</h4>
                    Total Prediksi Persalinan
                </div>
                <div class="card-footer d-flex align-items-center justify-content-between">
                    <a class="small text-white stretched-link" href="{{ route('bidan.prediksi.index') }}">Lihat Detail</a>
                    <div class="small text-white"><i class="fas fa-angle-right"></i></div>
                </div>
            </div>
        </div>
    </div>

    <!-- Daftar Ibu Hamil -->
    <div class="card mb-4">
        <div class="card-header">
            <i class="fas fa-table me-1"></i>
            Daftar Ibu Hamil
        </div>
        <div class="card-body">
            <div class="row">
                @forelse($ibuHamil as $ibu)
                <div class="col-xl-4 col-md-6 mb-4">
                    <div class="card border-left-primary h-100">
                        <div class="card-body">
                            <div class="d-flex justify-content-between">
                                <h5 class="card-title">{{ $ibu->name ?? 'Nama tidak tersedia' }}</h5>
                                <span class="badge bg-primary">Ibu Hamil</span>
                            </div>
                            <hr>
                            <div class="row mb-2">
                                <div class="col-md-4 fw-bold">NIK</div>
                                <div class="col-md-8">{{ $ibu->nik ?? '-' }}</div>
                            </div>
                            <div class="row mb-2">
                                <div class="col-md-4 fw-bold">Email</div>
                                <div class="col-md-8">{{ $ibu->email ?? '-' }}</div>
                            </div>
                            <div class="row mb-2">
                                <div class="col-md-4 fw-bold">Alamat</div>
                                <div class="col-md-8">{{ $ibu->alamat ?? '-' }}</div>
                            </div>
                            <div class="row mb-2">
                                <div class="col-md-4 fw-bold">No. HP</div>
                                <div class="col-md-8">{{ $ibu->no_hp ?? '-' }}</div>
                            </div>
                        </div>
                        <div class="card-footer">
                            <div class="d-flex justify-content-between">
                                <a href="{{ route('ibu_hamil.show', $ibu->id) }}" class="btn btn-sm btn-primary">Detail</a>
                                <a href="#" class="btn btn-sm btn-success">Riwayat Kesehatan</a>
                            </div>
                        </div>
                    </div>
                </div>
                @empty
                <div class="col-12">
                    <div class="alert alert-info">
                        Belum ada data ibu hamil yang terdaftar.
                    </div>
                </div>
                @endforelse
            </div>
        </div>
    </div>

    <!-- Deteksi Penyakit -->
    <div class="card mb-4">
        <div class="card-header">
            <i class="fas fa-heartbeat me-1"></i>
            Deteksi Penyakit Terbaru
        </div>
        <div class="card-body">
            <div class="row">
                @forelse($deteksiPenyakit->take(6) as $deteksi)
                <div class="col-xl-4 col-md-6 mb-4">
                    <div class="card border-left-warning h-100">
                        <div class="card-body">
                            <div class="d-flex justify-content-between">
                                <h5 class="card-title">{{ $deteksi->nama ?? 'Nama tidak tersedia' }}</h5>
                                <span class="badge bg-warning text-dark">Deteksi Penyakit</span>
                            </div>
                            <hr>
                            <div class="row mb-2">
                                <div class="col-md-6 fw-bold">Diabetes</div>
                                <div class="col-md-6">
                                    @if($deteksi->diabetes_prediction === 1)
                                        <span class="badge bg-danger">Positif</span>
                                    @elseif($deteksi->diabetes_prediction === 0)
                                        <span class="badge bg-success">Negatif</span>
                                    @else
                                        <span class="badge bg-secondary">Belum dideteksi</span>
                                    @endif
                                </div>
                            </div>
                            <div class="row mb-2">
                                <div class="col-md-6 fw-bold">Hipertensi</div>
                                <div class="col-md-6">
                                    @if($deteksi->hypertension_prediction === 1)
                                        <span class="badge bg-danger">Positif</span>
                                    @elseif($deteksi->hypertension_prediction === 0)
                                        <span class="badge bg-success">Negatif</span>
                                    @else
                                        <span class="badge bg-secondary">Belum dideteksi</span>
                                    @endif
                                </div>
                            </div>
                            <div class="row mb-2">
                                <div class="col-md-6 fw-bold">Kesehatan Maternal</div>
                                <div class="col-md-6">
                                    <span class="badge {{ $deteksi->maternal_health_prediction ? 'bg-info' : 'bg-secondary' }}">
                                        {{ $deteksi->maternal_health_prediction ?? 'Belum dideteksi' }}
                                    </span>
                                </div>
                            </div>
                            <div class="row mb-2">
                                <div class="col-md-6 fw-bold">Tekanan Darah</div>
                                <div class="col-md-6">{{ $deteksi->systolic_bp ?? '-' }}/{{ $deteksi->diastolic_bp ?? '-' }}</div>
                            </div>
                            <div class="row mb-2">
                                <div class="col-md-6 fw-bold">BMI</div>
                                <div class="col-md-6">{{ $deteksi->bmi ?? '-' }}</div>
                            </div>
                        </div>
                        <div class="card-footer">
                            <a href="#" class="btn btn-sm btn-warning w-100">Detail Lengkap</a>
                        </div>
                    </div>
                </div>
                @empty
                <div class="col-12">
                    <div class="alert alert-info">
                        Belum ada data deteksi penyakit.
                    </div>
                </div>
                @endforelse
            </div>
        </div>
    </div>

    <!-- Prediksi Depresi -->
    <div class="card mb-4">
        <div class="card-header">
            <i class="fas fa-brain me-1"></i>
            Prediksi Depresi Terbaru
        </div>
        <div class="card-body">
            <div class="row">
                @forelse($prediksiDepresi->take(6) as $depresi)
                <div class="col-xl-4 col-md-6 mb-4">
                    <div class="card border-left-success h-100">
                        <div class="card-body">
                            <div class="d-flex justify-content-between">
                                <h5 class="card-title">{{ $depresi->user->name ?? 'Tidak diketahui' }}</h5>

                                @if($depresi->epds && $depresi->epds->score)
                                    <!-- Badge untuk EPDS jika ada data -->
                                    <span class="badge
                                        @if($depresi->epds->score >= 14) bg-danger
                                        @elseif($depresi->epds->score >= 12) bg-warning
                                        @else bg-success
                                        @endif">
                                        @if($depresi->epds->score >= 14)
                                            Risiko Tinggi Depresi
                                        @elseif($depresi->epds->score >= 12)
                                            Kemungkinan Depresi
                                        @else
                                            Gejala Ringan
                                        @endif
                                        ({{ $depresi->epds->score }})
                                    </span>
                                @else
                                    <!-- Badge untuk prediksi depresi jika tidak ada EPDS -->
                                    <span class="badge {{ $depresi->hasil_prediksi ? 'bg-danger' : 'bg-success' }}">
                                        {{ $depresi->hasil_prediksi ? 'Bergejala Depresi' : 'Tidak Bergejala Depresi' }}
                                    </span>
                                @endif
                            </div>
                            <hr>
                            <div class="row mb-2">
                                <div class="col-md-6 fw-bold">Umur</div>
                                <div class="col-md-6">{{ $depresi->user->usia ?? '-' }} tahun</div>
                            </div>

                             <div class="row mb-2">
                                    <div class="col-md-6 fw-bold">Merasa Sedih</div>
                                    <div class="col-md-6">{{ $depresi->merasa_sedih_text }}</div>
                                </div>
                                <div class="row mb-2">
                                    <div class="col-md-6 fw-bold">Mudah Tersinggung</div>
                                    <div class="col-md-6">{{ $depresi->mudah_tersinggung_text}}</div>
                                </div>
                                <div class="row mb-2">
                                    <div class="col-md-6 fw-bold">Masalah Tidur</div>
                                    <div class="col-md-6">{{ $depresi->masalah_tidur_text}}</div>
                                </div>
                                <div class="row mb-2">
                                    <div class="col-md-6 fw-bold">Masalah Fokus</div>
                                    <div class="col-md-6">{{ $depresi->masalah_fokus_text}}</div>
                                </div>
                            @if($depresi->epds && $depresi->epds->score)
                                <!-- Tampilkan info EPDS jika ada -->
                                <div class="row mb-2">
                                    <div class="col-md-6 fw-bold">Skor EPDS</div>
                                    <div class="col-md-6">{{ $depresi->epds->score }} / 30</div>
                                </div>
                            @endif
                        </div>
                        <div class="card-footer">
                            <a href="{{ route('depresi.show', $depresi->id) }}" class="btn btn-sm btn-success w-100">Detail Lengkap</a>
                        </div>
                    </div>
                </div>
                @empty
                <div class="col-12">
                    <div class="alert alert-info">
                        Belum ada data prediksi depresi.
                    </div>
                </div>
                @endforelse
            </div>
        </div>
    </div>

<!-- Prediksi Janin / Persalinan -->
<div class="card mb-4">
    <div class="card-header bg-white text-dark fw-semibold">
        <i class="fas fa-baby me-1 text-danger"></i>
        Prediksi Persalinan Terbaru
    </div>
    <div class="card-body">
        <div class="row">
            @forelse($prediksiJanin->take(6) as $janin)
                @php
                    $method = strtolower($janin->metode_persalinan);
                    $isCaesar = $method === 'caesar';
                    $textClass = $isCaesar ? 'text-danger' : 'text-primary';
                    $borderClass = $isCaesar ? 'border-danger' : 'border-primary';
                    $buttonClass = $isCaesar ? 'btn-outline-danger' : 'btn-outline-primary';
                @endphp

                <div class="col-xl-4 col-md-6 mb-4">
                    <div class="card h-100 border border-2 {{ $borderClass }}">
                        <div class="card-body">
                            {{-- Header --}}
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h5 class="mb-0 fw-semibold">Prediksi #{{ $janin->id }}</h5>
                                <span class="fw-bold small {{ $textClass }}">
                                    {{ ucfirst($janin->metode_persalinan) }}
                                </span>
                            </div>

                            {{-- Informasi Klinis --}}
                            <div class="mb-2 d-flex justify-content-between">
                                <span><i class="fas fa-birthday-cake me-1 text-muted"></i> Usia Ibu</span>
                                <span>{{ $janin->usia_ibu }} tahun</span>
                            </div>
                            <div class="mb-2 d-flex justify-content-between">
                                <span><i class="fas fa-tachometer-alt me-1 text-muted"></i> Tekanan Darah</span>
                                <span>{{ ucfirst($janin->tekanan_darah) }}</span>
                            </div>
                            <div class="mb-2 d-flex justify-content-between">
                                <span><i class="fas fa-history me-1 text-muted"></i> Riwayat Persalinan</span>
                                <span>{{ ucfirst($janin->riwayat_persalinan) }}</span>
                            </div>
                            <div class="mb-2 d-flex justify-content-between">
                                <span><i class="fas fa-baby-carriage me-1 text-muted"></i> Posisi Janin</span>
                                <span>{{ ucfirst($janin->posisi_janin) }}</span>
                            </div>
                            <div class="mb-2 d-flex justify-content-between">
                                <span><i class="fas fa-heartbeat me-1 text-muted"></i> Kondisi Janin</span>
                                <span>{{ ucfirst($janin->kondisi_kesehatan_janin) ?? 'Normal' }}</span>
                            </div>
                        </div>

                        {{-- Footer --}}
                        <div class="card-footer bg-transparent border-top-0">
                            <a href="{{ route('bidan.prediksi.result', $janin->id) }}"
                               class="btn btn-sm {{ $buttonClass }} w-100">
                                <i class="fas fa-eye me-1"></i> Lihat Detail
                            </a>
                        </div>
                    </div>
                </div>
            @empty
                <div class="col-12">
                    <div class="alert alert-info">Belum ada data prediksi persalinan.</div>
                </div>
            @endforelse
        </div>
    </div>
</div>
@endsection
