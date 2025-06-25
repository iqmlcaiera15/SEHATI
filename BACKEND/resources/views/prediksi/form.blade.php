@extends('layouts.app')

@section('content')
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
                                Form Prediksi Persalinan
                            </h2>
                            <span class="opacity-75">
                                Mohon isi data berikut dengan lengkap dan benar agar hasil prediksi lebih akurat.<br>
                                Semua kolom wajib diisi, gunakan kata sederhana, misal: <b>“tidak ada”</b> jika sehat.
                            </span>
                        </div>
                        <a href="{{ route('prediksi.index') }}" class="btn btn-outline-light d-flex align-items-center shadow-sm px-4 rounded-3 fw-semibold">
                            <i class="fas fa-arrow-left me-2"></i> Kembali
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Error Alert Friendly -->
    @if ($errors->any())
        <div class="alert alert-danger shadow-sm rounded-3 mb-4">
            <strong>Mohon lengkapi isian berikut:</strong>
            <ul class="mb-0 mt-2">
                @foreach ($errors->all() as $error)
                    <li>
                        @php
                            $map = [
                                'The user id field is required.' => 'Nama ibu hamil belum dipilih.',
                                'The usia ibu field is required.' => 'Usia ibu belum diisi.',
                                'The tekanan darah field is required.' => 'Tekanan darah belum dipilih.',
                                'The riwayat persalinan field is required.' => 'Riwayat persalinan belum dipilih.',
                                'The posisi janin field is required.' => 'Posisi janin belum dipilih.',
                                'The riwayat kesehatan ibu field is required.' => 'Riwayat kesehatan ibu belum diisi.',
                                'The kondisi kesehatan janin field is required.' => 'Kondisi kesehatan janin belum diisi.',
                                'The usia ibu must be between 15 and 50.' => 'Usia ibu harus antara 15 sampai 50 tahun.',
                                'The usia ibu must be at least 15.' => 'Usia ibu minimal 15 tahun.',
                                'The usia ibu may not be greater than 50.' => 'Usia ibu maksimal 50 tahun.',
                            ];
                        @endphp
                        {{ $map[$error] ?? $error }}
                    </li>
                @endforeach
            </ul>
        </div>
    @endif
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

    <!-- Form Card -->
    <div class="row justify-content-center">
        <div class="col-lg-8 col-md-10">
            <div class="card shadow-sm border-0" style="border-radius: 18px;">
                <div class="card-body px-4 py-4">

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
                                    @error('user_id')
                                        <div class="text-danger small mt-1">Nama ibu hamil wajib dipilih.</div>
                                    @enderror
                                </div>
                            @else
                                <input type="hidden" name="user_id" value="{{ Auth::user()->id }}">
                            @endif

                            <div class="col-md-6">
                                <label for="usia_ibu" class="form-label fw-semibold">
                                    Usia Ibu <span class="text-danger">*</span>
                                </label>
                                <input type="number" id="usia_ibu" name="usia_ibu" class="form-control rounded-3" min="15" max="50"
                                    value="{{ old('usia_ibu') }}" required placeholder="Isi usia ibu, contoh: 28">
                                <small class="text-muted">Masukkan usia antara 15 sampai 50 tahun</small>
                                @error('usia_ibu')
                                    <div class="text-danger small mt-1">{{ $message == "The usia ibu field is required." ? "Usia ibu belum diisi." : $message }}</div>
                                @enderror
                            </div>

                            <div class="col-md-6">
                                <label for="tekanan_darah" class="form-label fw-semibold">
                                    Tekanan Darah <span class="text-danger">*</span>
                                </label>
                                <select id="tekanan_darah" name="tekanan_darah" class="form-select rounded-3" required>
                                    <option value="">-- Pilih --</option>
                                    <option value="normal" {{ old('tekanan_darah') == 'normal' ? 'selected' : '' }}>Normal</option>
                                    <option value="rendah" {{ old('tekanan_darah') == 'rendah' ? 'selected' : '' }}>Rendah</option>
                                    <option value="tinggi" {{ old('tekanan_darah') == 'tinggi' ? 'selected' : '' }}>Tinggi</option>
                                </select>
                                @error('tekanan_darah')
                                    <div class="text-danger small mt-1">Tekanan darah wajib dipilih.</div>
                                @enderror
                            </div>

                            <div class="col-md-6">
                                <label for="riwayat_persalinan" class="form-label fw-semibold">
                                    Riwayat Persalinan <span class="text-danger">*</span>
                                </label>
                                <select id="riwayat_persalinan" name="riwayat_persalinan" class="form-select rounded-3" required>
                                    <option value="">-- Pilih --</option>
                                    <option value="tidak ada" {{ old('riwayat_persalinan') == 'tidak ada' ? 'selected' : '' }}>Tidak Ada</option>
                                    <option value="normal" {{ old('riwayat_persalinan') == 'normal' ? 'selected' : '' }}>Normal</option>
                                    <option value="caesar" {{ old('riwayat_persalinan') == 'caesar' ? 'selected' : '' }}>Caesar</option>
                                </select>
                                @error('riwayat_persalinan')
                                    <div class="text-danger small mt-1">Riwayat persalinan wajib dipilih.</div>
                                @enderror
                            </div>

                            <div class="col-md-6">
                                <label for="posisi_janin" class="form-label fw-semibold">
                                    Posisi Janin <span class="text-danger">*</span>
                                </label>
                                <select id="posisi_janin" name="posisi_janin" class="form-select rounded-3" required>
                                    <option value="">-- Pilih --</option>
                                    <option value="normal" {{ old('posisi_janin') == 'normal' ? 'selected' : '' }}>Normal</option>
                                    <option value="lintang" {{ old('posisi_janin') == 'lintang' ? 'selected' : '' }}>Lintang</option>
                                    <option value="sungsang" {{ old('posisi_janin') == 'sungsang' ? 'selected' : '' }}>Sungsang</option>
                                </select>
                                @error('posisi_janin')
                                    <div class="text-danger small mt-1">Posisi janin wajib dipilih.</div>
                                @enderror
                            </div>

                            <div class="col-md-6">
                                <label for="riwayat_kesehatan_ibu" class="form-label fw-semibold">
                                    Riwayat Kesehatan Ibu <span class="text-danger">*</span>
                                </label>
                                <input type="text" id="riwayat_kesehatan_ibu" name="riwayat_kesehatan_ibu" class="form-control rounded-3"
                                    value="{{ old('riwayat_kesehatan_ibu') }}" required placeholder="Contoh: hipertensi, tidak ada">
                                <small class="text-muted">Tulis penyakit seperti “hipertensi”, atau jika sehat tulis “tidak ada”. Tidak boleh angka saja.</small>
                                <div id="err_kesehatan_ibu" class="text-danger small mt-1" style="display:none">
                                    Mohon isi dengan huruf/kalimat, tidak boleh hanya angka.
                                </div>
                                @error('riwayat_kesehatan_ibu')
                                    <div class="text-danger small mt-1">Riwayat kesehatan ibu wajib diisi.</div>
                                @enderror
                            </div>

                            <div class="col-md-6">
                                <label for="kondisi_kesehatan_janin" class="form-label fw-semibold">
                                    Kondisi Kesehatan Janin <span class="text-danger">*</span>
                                </label>
                                <input type="text" id="kondisi_kesehatan_janin" name="kondisi_kesehatan_janin" class="form-control rounded-3"
                                    value="{{ old('kondisi_kesehatan_janin') }}" required placeholder="Contoh: normal, detak jantung lambat">
                                <small class="text-muted">Tulis “normal” jika sehat. Tidak boleh hanya angka.</small>
                                <div id="err_kesehatan_janin" class="text-danger small mt-1" style="display:none">
                                    Mohon isi dengan huruf/kalimat, tidak boleh hanya angka.
                                </div>
                                @error('kondisi_kesehatan_janin')
                                    <div class="text-danger small mt-1">Kondisi janin wajib diisi.</div>
                                @enderror
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
        // Validasi input: tidak boleh hanya angka untuk field kesehatan
        function cekString(fieldId, msgId) {
            const field = document.getElementById(fieldId);
            const msg = document.getElementById(msgId);
            field.addEventListener('input', function() {
                if (/^\d+$/.test(field.value)) {
                    msg.style.display = 'block';
                } else {
                    msg.style.display = 'none';
                }
            });
        }
        cekString('riwayat_kesehatan_ibu', 'err_kesehatan_ibu');
        cekString('kondisi_kesehatan_janin', 'err_kesehatan_janin');

        // Bootstrap tooltip & validation
        const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl);
        });

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
