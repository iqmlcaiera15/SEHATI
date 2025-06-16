@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-12">
            <div class="card shadow-lg">
                <div class="card-header bg-primary text-white">
                    <h3 class="mb-0"><i class="fas fa-heartbeat me-2"></i>Form Deteksi Penyakit</h3>
                    <small class="text-light">Mohon isi form dengan data yang akurat untuk hasil deteksi yang optimal</small>
                </div>

                <div class="card-body">
                    @if(session('error'))
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-triangle me-2"></i>{{ session('error') }}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    @endif

                    <form method="POST" action="{{ route('deteksi.store') }}">
                        @csrf
                        
                        <div class="row mb-4">
                            <div class="col-md-12"><h4 class="text-primary mb-3"><i class="fas fa-user me-2"></i>Data Pribadi</h4></div>
                            
                            <div class="col-md-6 mb-3">
                                <label for="nama" class="form-label"><i class="fas fa-user me-1"></i>Nama Lengkap <span class="text-danger">*</span></label>
                                <input type="text" class="form-control @error('nama') is-invalid @enderror" id="nama" name="nama" value="{{ old('nama') }}" placeholder="Masukkan nama lengkap" required>
                                <div class="form-text"><i class="fas fa-info-circle me-1"></i>Gunakan nama lengkap sesuai identitas</div>
                                @error('nama')<div class="invalid-feedback">{{ $message }}</div>@enderror
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <label for="age" class="form-label"><i class="fas fa-calendar-alt me-1"></i>Umur <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <input type="number" class="form-control @error('age') is-invalid @enderror" id="age" name="age" value="{{ old('age') }}" placeholder="25" min="15" max="100" required>
                                    <span class="input-group-text">tahun</span>
                                </div>
                                <div class="form-text"><i class="fas fa-info-circle me-1"></i>Masukkan umur dalam tahun (15-100 tahun)</div>
                                @error('age')<div class="invalid-feedback">{{ $message }}</div>@enderror
                            </div>
                        </div>
                        
                        <div class="row mb-4">
                            <div class="col-md-12"><h4 class="text-primary mb-3"><i class="fas fa-weight me-2"></i>Data Fisik</h4></div>
                            
                            <div class="col-md-4 mb-3">
                                <label for="tinggi_badan" class="form-label"><i class="fas fa-ruler-vertical me-1"></i>Tinggi Badan <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <input type="number" step="0.1" class="form-control @error('tinggi_badan') is-invalid @enderror" id="tinggi_badan" name="tinggi_badan" value="{{ old('tinggi_badan') }}" placeholder="160" min="100" max="250" required>
                                    <span class="input-group-text">cm</span>
                                </div>
                                @error('tinggi_badan')<div class="invalid-feedback">{{ $message }}</div>@enderror
                            </div>

                            <div class="col-md-4 mb-3">
                                <label for="berat_badan" class="form-label"><i class="fas fa-weight me-1"></i>Berat Badan <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <input type="number" step="0.1" class="form-control @error('berat_badan') is-invalid @enderror" id="berat_badan" name="berat_badan" value="{{ old('berat_badan') }}" placeholder="55" min="30" max="200" required>
                                    <span class="input-group-text">kg</span>
                                </div>
                                @error('berat_badan')<div class="invalid-feedback">{{ $message }}</div>@enderror
                            </div>
                            
                            <div class="col-md-4 mb-3">
                                <label for="bmi_display" class="form-label"><i class="fas fa-calculator me-1"></i>BMI (Dihitung Otomatis)</label>
                                <div class="input-group">
                                    <input type="text" class="form-control bg-light @error('bmi') is-invalid @enderror" id="bmi_display" readonly placeholder="Hasil BMI">
                                    <span class="input-group-text">kg/m²</span>
                                </div>
                                <div class="form-text"><i class="fas fa-info-circle me-1"></i><small>Normal: 18.5-24.9</small></div>
                                <input type="hidden" id="bmi" name="bmi" value="{{ old('bmi') }}">
                                @error('bmi')<div class="invalid-feedback">{{ $message }}</div>@enderror
                            </div>

                            <div class="col-md-4 mb-3">
                                <label for="systolic_bp" class="form-label"><i class="fas fa-heartbeat me-1"></i>Tekanan Sistolik <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <input type="number" class="form-control @error('systolic_bp') is-invalid @enderror" id="systolic_bp" name="systolic_bp" value="{{ old('systolic_bp', 120) }}" placeholder="120" min="80" max="250" required>
                                    <span class="input-group-text">mmHg</span>
                                </div>
                                @error('systolic_bp')<div class="invalid-feedback">{{ $message }}</div>@enderror
                            </div>
                            
                            <div class="col-md-4 mb-3">
                                <label for="diastolic_bp" class="form-label"><i class="fas fa-heartbeat me-1"></i>Tekanan Diastolik <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <input type="number" class="form-control @error('diastolic_bp') is-invalid @enderror" id="diastolic_bp" name="diastolic_bp" value="{{ old('diastolic_bp', 80) }}" placeholder="80" min="50" max="150" required>
                                    <span class="input-group-text">mmHg</span>
                                </div>
                                @error('diastolic_bp')<div class="invalid-feedback">{{ $message }}</div>@enderror
                            </div>

                            <div class="col-md-4 mb-3">
                                <label class="form-label"><i class="fas fa-chart-line me-1"></i>Mean Arterial Pressure (MAP)</label>
                                <div class="input-group">
                                    <input type="text" class="form-control bg-light" id="map_display" readonly placeholder="Akan dihitung otomatis">
                                    <span class="input-group-text">mmHg</span>
                                </div>
                            </div>
                        </div>
                        
                        <div class="row mb-4">
                            <div class="col-md-12"><h4 class="text-primary mb-3"><i class="fas fa-stethoscope me-2"></i>Data Kesehatan</h4></div>
                            
                            <div class="col-md-4 mb-3">
                                <label for="bs" class="form-label"><i class="fas fa-tint me-1"></i>Gula Darah <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <input type="number" step="0.1" class="form-control @error('bs') is-invalid @enderror" id="bs" name="bs" value="{{ old('bs') }}" placeholder="100" min="50" max="500" required>
                                    <span class="input-group-text">mg/dL</span>
                                </div>
                                @error('bs')<div class="invalid-feedback">{{ $message }}</div>@enderror
                            </div>
                            
                            <div class="col-md-4 mb-3">
                                <label for="pregnancies" class="form-label"><i class="fas fa-baby me-1"></i>Jumlah Kehamilan <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <input type="number" class="form-control @error('pregnancies') is-invalid @enderror" id="pregnancies" name="pregnancies" value="{{ old('pregnancies', 0) }}" placeholder="0" min="0" max="20" required>
                                    <span class="input-group-text">kali</span>
                                </div>
                                @error('pregnancies')<div class="invalid-feedback">{{ $message }}</div>@enderror
                            </div>

                             <div class="col-md-4 mb-3">
                                <label for="heart_rate" class="form-label"><i class="fas fa-heart me-1"></i>Detak Jantung</label>
                                <div class="input-group">
                                    <input type="number" class="form-control @error('heart_rate') is-invalid @enderror" id="heart_rate" name="heart_rate" value="{{ old('heart_rate', 70) }}" placeholder="70" min="40" max="200">
                                    <span class="input-group-text">bpm</span>
                                </div>
                                @error('heart_rate')<div class="invalid-feedback">{{ $message }}</div>@enderror
                            </div>
                        </div>

                        <div class="d-flex justify-content-between">
                           <a href="{{ route('deteksi.index') }}" class="btn btn-outline-secondary btn-lg"><i class="fas fa-arrow-left me-2"></i>Kembali</a>
                           <button type="submit" class="btn btn-primary btn-lg"><i class="fas fa-paper-plane me-2"></i>Mulai Deteksi</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script>
document.addEventListener('DOMContentLoaded', function() {
    // --- Get all required elements ---
    const smokerSelect = document.getElementById('current_smoker');
    const cigsContainer = document.getElementById('cigs_container');
    const systolicInput = document.getElementById('systolic_bp');
    const diastolicInput = document.getElementById('diastolic_bp');
    const mapDisplay = document.getElementById('map_display');
    
    // --- NEW: Elements for BMI calculation ---
    const tinggiInput = document.getElementById('tinggi_badan');
    const beratInput = document.getElementById('berat_badan');
    const bmiDisplay = document.getElementById('bmi_display');
    const bmiHidden = document.getElementById('bmi');

    // Toggle cigarettes per day field
    function toggleCigsPerDay() {
        if (!smokerSelect) return;
        if (smokerSelect.value === '1') {
            cigsContainer.style.display = 'block';
        } else {
            cigsContainer.style.display = 'none';
            document.getElementById('cigs_per_day').value = '0';
        }
    }
    
    // Calculate MAP (Mean Arterial Pressure)
    function calculateMAP() {
        const systolic = parseFloat(systolicInput.value) || 0;
        const diastolic = parseFloat(diastolicInput.value) || 0;
        
        if (systolic > 0 && diastolic > 0) {
            const map = ((systolic + (2 * diastolic)) / 3).toFixed(1);
            mapDisplay.value = map;
        } else {
            mapDisplay.value = '';
        }
    }
    
    // --- NEW: Function to calculate BMI ---
    function calculateBMI() {
        const tinggi = parseFloat(tinggiInput.value) || 0;
        const berat = parseFloat(beratInput.value) || 0;

        // Check if values are valid for calculation
        if (tinggi > 0 && berat > 0) {
            // Convert height from cm to meters
            const tinggiM = tinggi / 100;
            // Calculate BMI: kg / (m * m)
            const bmi = berat / (tinggiM * tinggiM);
            const bmiFormatted = bmi.toFixed(1);

            // Update display and hidden fields
            bmiDisplay.value = bmiFormatted;
            bmiHidden.value = bmiFormatted;

            // Optional: Add color coding for BMI display
            bmiDisplay.classList.remove('text-success', 'text-warning', 'text-danger');
            if (bmi < 18.5) {
                bmiDisplay.classList.add('text-warning');
            } else if (bmi >= 18.5 && bmi <= 24.9) {
                bmiDisplay.classList.add('text-success');
            } else {
                bmiDisplay.classList.add('text-danger');
            }
        } else {
            // Clear fields if input is not valid
            bmiDisplay.value = '';
            bmiHidden.value = '';
        }
    }

    // --- Event listeners ---
    if (smokerSelect) {
        smokerSelect.addEventListener('change', toggleCigsPerDay);
    }
    systolicInput.addEventListener('input', calculateMAP);
    diastolicInput.addEventListener('input', calculateMAP);

    // --- NEW: Event listeners for BMI calculation ---
    tinggiInput.addEventListener('input', calculateBMI);
    beratInput.addEventListener('input', calculateBMI);
    
    // --- Initial calculations on page load (for old data) ---
    if (smokerSelect) {
        toggleCigsPerDay();
    }
    calculateMAP();
    calculateBMI(); 
});
</script>
@endsection

@section('styles')
{{-- You can add the same styles you had before here if they are not in a global stylesheet --}}
<style>
.form-control:focus {
    border-color: #0d6efd;
    box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.25);
}
.text-success { color: #198754 !important; }
.text-warning { color: #ffc107 !important; }
.text-danger  { color: #dc3545 !important; }

/* ... other styles ... */
</style>
@endsection