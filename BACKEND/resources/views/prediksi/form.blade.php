@extends('layouts.app')

@section('content')
<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h3 class="text-primary fw-semibold border-start border-4 ps-3 border-success">
            <i class="fas fa-stethoscope me-2"></i> Form Prediksi Metode Persalinan
        </h3>
        <a href="{{ route('bidan.prediksi.index') }}" class="btn btn-outline-secondary">
            <i class="fas fa-arrow-left me-1"></i> Kembali
        </a>
    </div>

    <p class="text-muted mb-4">
        Silakan isi data berikut secara lengkap untuk mendapatkan hasil prediksi metode persalinan berdasarkan kondisi ibu dan janin.
    </p>

    @if ($errors->any())
        <div class="alert alert-danger shadow-sm">
            <strong>Terjadi kesalahan:</strong>
            <ul class="mb-0 mt-2">
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <div class="card shadow-sm border-0 bg-light">
        <div class="card-body">
            <form action="{{ route('bidan.prediksi.store') }}" method="POST" class="needs-validation" novalidate>
                @csrf

                <div class="row g-3">
                    <div class="col-md-6">
                        <label for="usia_ibu" class="form-label">
                            Usia Ibu (tahun) <span class="text-danger">*</span>
                            <i class="fas fa-circle-info text-info ms-1" data-bs-toggle="tooltip" title="Masukkan usia ibu antara 15 hingga 50 tahun."></i>
                        </label>
                        <input type="number" id="usia_ibu" name="usia_ibu" class="form-control" min="15" max="50" required placeholder="Contoh: 28">
                        <div class="invalid-feedback">Usia ibu wajib diisi (15-50).</div>
                    </div>

                    <div class="col-md-6">
                        <label for="tekanan_darah" class="form-label">
                            Tekanan Darah <span class="text-danger">*</span>
                            <i class="fas fa-circle-info text-info ms-1" data-bs-toggle="tooltip" title="Pilih kategori tekanan darah saat pemeriksaan."></i>
                        </label>
                        <select id="tekanan_darah" name="tekanan_darah" class="form-select" required>
                            <option value="">-- Pilih --</option>
                            <option value="normal">Normal</option>
                            <option value="rendah">Rendah</option>
                            <option value="tinggi">Tinggi</option>
                        </select>
                        <div class="invalid-feedback">Tekanan darah wajib dipilih.</div>
                    </div>

                    <div class="col-md-6">
                        <label for="riwayat_persalinan" class="form-label">
                            Riwayat Persalinan <span class="text-danger">*</span>
                            <i class="fas fa-circle-info text-info ms-1" data-bs-toggle="tooltip" title="Pilih metode persalinan yang pernah dialami sebelumnya."></i>
                        </label>
                        <select id="riwayat_persalinan" name="riwayat_persalinan" class="form-select" required>
                            <option value="">-- Pilih --</option>
                            <option value="tidak ada">Tidak Ada</option>
                            <option value="normal">Normal</option>
                            <option value="caesar">Caesar</option>
                        </select>
                        <div class="invalid-feedback">Riwayat persalinan wajib dipilih.</div>
                    </div>

                    <div class="col-md-6">
                        <label for="posisi_janin" class="form-label">
                            Posisi Janin <span class="text-danger">*</span>
                            <i class="fas fa-circle-info text-info ms-1" data-bs-toggle="tooltip" title="Posisi janin terakhir berdasarkan pemeriksaan."></i>
                        </label>
                        <select id="posisi_janin" name="posisi_janin" class="form-select" required>
                            <option value="">-- Pilih --</option>
                            <option value="normal">Normal</option>
                            <option value="lintang">Lintang</option>
                            <option value="sungsang">Sungsang</option>
                        </select>
                        <div class="invalid-feedback">Posisi janin wajib dipilih.</div>
                    </div>

                    <div class="col-md-6">
                        <label for="riwayat_kesehatan_ibu" class="form-label">
                            Riwayat Kesehatan Ibu <span class="text-danger">*</span>
                            <i class="fas fa-circle-info text-info ms-1" data-bs-toggle="tooltip" title="Contoh: diabetes, hipertensi, anemia. Wajib diisi."></i>
                        </label>
                        <input type="text" id="riwayat_kesehatan_ibu" name="riwayat_kesehatan_ibu" class="form-control" required placeholder="Contoh: hipertensi">
                        <div class="invalid-feedback">Riwayat kesehatan ibu wajib diisi.</div>
                    </div>

                    <div class="col-md-6">
                        <label for="kondisi_kesehatan_janin" class="form-label">
                            Kondisi Kesehatan Janin <span class="text-danger">*</span>
                            <i class="fas fa-circle-info text-info ms-1" data-bs-toggle="tooltip" title="Contoh: normal, detak jantung lambat, kelainan. Wajib diisi."></i>
                        </label>
                        <input type="text" id="kondisi_kesehatan_janin" name="kondisi_kesehatan_janin" class="form-control" required placeholder="Contoh: normal">
                        <div class="invalid-feedback">Kondisi janin wajib diisi.</div>
                    </div>
                </div>

                <div class="mt-4 text-end">
                    <button type="submit" class="btn btn-success btn-lg shadow-sm px-4">
                        <i class="fas fa-check-circle me-1"></i> Prediksi Sekarang
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
    // Tooltip & Bootstrap validation
    document.addEventListener('DOMContentLoaded', function () {
        const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
        tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl)
        });

        const forms = document.querySelectorAll('.needs-validation')
        Array.from(forms).forEach(function (form) {
            form.addEventListener('submit', function (event) {
                if (!form.checkValidity()) {
                    event.preventDefault()
                    event.stopPropagation()
                }
                form.classList.add('was-validated')
            }, false)
        });
    });
</script>
@endpush
