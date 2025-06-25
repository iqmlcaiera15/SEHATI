@extends('layouts.app')

@section('content')
<div class="container-fluid py-4">

    <!-- Header Section: sama dengan index -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="card border-0 shadow-sm" style="background: linear-gradient(135deg, #4dbaff 0%, #1a87e3 100%); border-radius: 15px;">
                <div class="card-body text-white">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h2 class="mb-2">
                                <i class="fas fa-baby me-2"></i>
                                Form Prediksi Persalinan
                            </h2>
                            <span class="opacity-75">Isi data berikut untuk hasil prediksi metode persalinan yang akurat</span>
                        </div>
                        <a href="{{ route('prediksi.index') }}" class="btn btn-outline-light d-flex align-items-center shadow-sm px-4 rounded-3 fw-semibold">
                            <i class="fas fa-arrow-left me-2"></i> Kembali
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Error/Session Alert -->
    @if(session('error'))
        <div class="alert alert-danger shadow-sm rounded-3 mb-4">
            {{ session('error') }}
        </div>
    @endif
    @if(session('success'))
        <div class="alert alert-success shadow-sm rounded-3 mb-4">
            {{ session('success') }}
        </div>
    @endif
    @if ($errors->any())
        <div class="alert alert-danger shadow-sm rounded-3 mb-4">
            <strong>Terjadi kesalahan:</strong>
            <ul class="mb-0 mt-2">
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <!-- Form Card -->
    <div class="row justify-content-center">
        <div class="col-lg-9">
            <div class="card shadow-sm border-0" style="border-radius: 18px;">
                <div class="card-body p-4">

                    <form action="{{ route('prediksi.store') }}" method="POST" class="needs-validation" novalidate autocomplete="off">
                        @csrf

                        <div class="row g-4">
                            {{-- Bidan: Pilih user --}}
                            @if(Auth::user()->role === 'bidan')
                                <div class="col-md-6">
                                    <label for="user_id" class="form-label fw-semibold">
                                        Nama Ibu Hamil <span class="text-danger">*</span>
                                    </label>
                                    <select id="user_id" name="user_id" class="form-select rounded-3" required>
                                        <option value="">-- Pilih Ibu Hamil --</option>
                                        @foreach($users as $user)
                                            @if($user->role === 'ibu_hamil')
                                                <option value="{{ $user->id }}" {{ old('user_id') == $user->id ? 'selected' : '' }}>
                                                    {{ $user->name }}
                                                </option>
                                            @endif
                                        @endforeach
                                    </select>
                                    <div class="invalid-feedback">Nama ibu wajib dipilih.</div>
                                </div>
                            @else
                                <input type="hidden" name="user_id" value="{{ Auth::user()->id }}">
                            @endif

                            <div class="col-md-6">
                                <label for="usia_ibu" class="form-label fw-semibold">
                                    Usia Ibu (tahun) <span class="text-danger">*</span>
                                    <i class="fas fa-circle-info text-info ms-1" data-bs-toggle="tooltip" title="Masukkan usia ibu antara 15 hingga 50 tahun."></i>
                                </label>
                                <input type="number" id="usia_ibu" name="usia_ibu" class="form-control rounded-3" min="15" max="50"
                                    value="{{ old('usia_ibu') }}" required placeholder="Contoh: 28">
                                <div class="invalid-feedback">Usia ibu wajib diisi (15-50).</div>
                            </div>

                            <div class="col-md-6">
                                <label for="tekanan_darah" class="form-label fw-semibold">
                                    Tekanan Darah <span class="text-danger">*</span>
                                    <i class="fas fa-circle-info text-info ms-1" data-bs-toggle="tooltip" title="Pilih kategori tekanan darah saat pemeriksaan."></i>
                                </label>
                                <select id="tekanan_darah" name="tekanan_darah" class="form-select rounded-3" required>
                                    <option value="">-- Pilih --</option>
                                    <option value="normal" {{ old('tekanan_darah') == 'normal' ? 'selected' : '' }}>Normal</option>
                                    <option value="rendah" {{ old('tekanan_darah') == 'rendah' ? 'selected' : '' }}>Rendah</option>
                                    <option value="tinggi" {{ old('tekanan_darah') == 'tinggi' ? 'selected' : '' }}>Tinggi</option>
                                </select>
                                <div class="invalid-feedback">Tekanan darah wajib dipilih.</div>
                            </div>

                            <div class="col-md-6">
                                <label for="riwayat_persalinan" class="form-label fw-semibold">
                                    Riwayat Persalinan <span class="text-danger">*</span>
                                    <i class="fas fa-circle-info text-info ms-1" data-bs-toggle="tooltip" title="Pilih metode persalinan yang pernah dialami sebelumnya."></i>
                                </label>
                                <select id="riwayat_persalinan" name="riwayat_persalinan" class="form-select rounded-3" required>
                                    <option value="">-- Pilih --</option>
                                    <option value="tidak ada" {{ old('riwayat_persalinan') == 'tidak ada' ? 'selected' : '' }}>Tidak Ada</option>
                                    <option value="normal" {{ old('riwayat_persalinan') == 'normal' ? 'selected' : '' }}>Normal</option>
                                    <option value="caesar" {{ old('riwayat_persalinan') == 'caesar' ? 'selected' : '' }}>Caesar</option>
                                </select>
                                <div class="invalid-feedback">Riwayat persalinan wajib dipilih.</div>
                            </div>

                            <div class="col-md-6">
                                <label for="posisi_janin" class="form-label fw-semibold">
                                    Posisi Janin <span class="text-danger">*</span>
                                    <i class="fas fa-circle-info text-info ms-1" data-bs-toggle="tooltip" title="Posisi janin terakhir berdasarkan pemeriksaan."></i>
                                </label>
                                <select id="posisi_janin" name="posisi_janin" class="form-select rounded-3" required>
                                    <option value="">-- Pilih --</option>
                                    <option value="normal" {{ old('posisi_janin') == 'normal' ? 'selected' : '' }}>Normal</option>
                                    <option value="lintang" {{ old('posisi_janin') == 'lintang' ? 'selected' : '' }}>Lintang</option>
                                    <option value="sungsang" {{ old('posisi_janin') == 'sungsang' ? 'selected' : '' }}>Sungsang</option>
                                </select>
                                <div class="invalid-feedback">Posisi janin wajib dipilih.</div>
                            </div>

                            <div class="col-md-6">
                                <label for="riwayat_kesehatan_ibu" class="form-label fw-semibold">
                                    Riwayat Kesehatan Ibu <span class="text-danger">*</span>
                                    <i class="fas fa-circle-info text-info ms-1" data-bs-toggle="tooltip" title="Contoh: diabetes, hipertensi, anemia. Wajib diisi."></i>
                                </label>
                                <input type="text" id="riwayat_kesehatan_ibu" name="riwayat_kesehatan_ibu" class="form-control rounded-3"
                                    value="{{ old('riwayat_kesehatan_ibu') }}" required placeholder="Contoh: hipertensi">
                                <div class="invalid-feedback">Riwayat kesehatan ibu wajib diisi.</div>
                            </div>

                            <div class="col-md-6">
                                <label for="kondisi_kesehatan_janin" class="form-label fw-semibold">
                                    Kondisi Kesehatan Janin <span class="text-danger">*</span>
                                    <i class="fas fa-circle-info text-info ms-1" data-bs-toggle="tooltip" title="Contoh: normal, detak jantung lambat, kelainan. Wajib diisi."></i>
                                </label>
                                <input type="text" id="kondisi_kesehatan_janin" name="kondisi_kesehatan_janin" class="form-control rounded-3"
                                    value="{{ old('kondisi_kesehatan_janin') }}" required placeholder="Contoh: normal">
                                <div class="invalid-feedback">Kondisi janin wajib diisi.</div>
                            </div>
                        </div>

                        <div class="mt-5 text-end">
                            <button type="submit" class="btn btn-lg px-5 py-3 fw-bold d-flex align-items-center gap-2 shadow-sm rounded-3"
                                style="background: linear-gradient(45deg, #4dbaff, #1a87e3); border: none; color: white;">
                                <i class="fas fa-check-circle me-2"></i>
                                Prediksi Sekarang
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Custom Styles -->
<style>
    .card, .btn, .alert { transition: all 0.3s; }
    .btn-success, .btn-primary {
        font-weight: 600; letter-spacing: .5px;
    }
    .form-label { font-weight: 500; }
    .needs-validation .form-control:invalid,
    .needs-validation .form-select:invalid {
        border-color: #dc3545;
    }
</style>
@endsection

@push('scripts')
<script>
    document.addEventListener('DOMContentLoaded', function () {
        // Tooltip
        const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl);
        });

        // Bootstrap validation
        const forms = document.querySelectorAll('.needs-validation');
        Array.from(forms).forEach(function (form) {
            form.addEventListener('submit', function (event) {
                if (!form.checkValidity()) {
                    event.preventDefault();
                    event.stopPropagation();
                }
                form.classList.add('was-validated');
            }, false);
        });
    });
</script>
@endpush
