@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header">
                    <h3>Form Deteksi Penyakit</h3>
                </div>

                <div class="card-body">
                    @if(session('error'))
                        <div class="alert alert-danger">
                            {{ session('error') }}
                        </div>
                    @endif

                    <form method="POST" action="{{ route('deteksi.store') }}">
                        @csrf
                        
                        <div class="row mb-4">
                            <div class="col-md-12">
                                <h4>Data Pribadi</h4>
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <label for="nama" class="form-label">Nama Lengkap <span class="text-danger">*</span></label>
                                <input type="text" class="form-control @error('nama') is-invalid @enderror" id="nama" name="nama" value="{{ old('nama') }}" required>
                                @error('nama')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                            
                            <div class="col-md-3 mb-3">
                                <label for="age" class="form-label">Umur (tahun) <span class="text-danger">*</span></label>
                                <input type="number" class="form-control @error('age') is-invalid @enderror" id="age" name="age" value="{{ old('age') }}" required>
                                @error('age')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                            
                            <div class="col-md-3 mb-3">
                                <label for="sex" class="form-label">Jenis Kelamin</label>
                                <select class="form-select @error('sex') is-invalid @enderror" id="sex" name="sex">
                                    <option value="">Pilih Jenis Kelamin</option>
                                    <option value="1" {{ old('sex') == '0' ? 'selected' : '' }}>Laki-laki</option>
                                    <option value="0" {{ old('sex') == '1' ? 'selected' : '' }}>Perempuan</option>
                                </select>
                                @error('sex')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                        
                        <div class="row mb-4">
                            <div class="col-md-12">
                                <h4>Data Fisik</h4>
                            </div>
                            
                            <div class="col-md-4 mb-3">
                                <label for="bmi" class="form-label">BMI <span class="text-danger">*</span></label>
                                <input type="number" step="0.01" class="form-control @error('bmi') is-invalid @enderror" id="bmi" name="bmi" value="{{ old('bmi') }}" required>
                                @error('bmi')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                            
                            <div class="col-md-4 mb-3">
                                <label for="blood_pressure" class="form-label">Tekanan Darah <span class="text-danger">*</span></label>
                                <input type="number" class="form-control @error('blood_pressure') is-invalid @enderror" id="blood_pressure" name="blood_pressure" value="{{ old('blood_pressure') }}" required>
                                @error('blood_pressure')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                            
                            <div class="col-md-4 mb-3">
                                <label for="skin_thickness" class="form-label">Ketebalan Kulit</label>
                                <input type="number" step="0.01" class="form-control @error('skin_thickness') is-invalid @enderror" id="skin_thickness" name="skin_thickness" value="{{ old('skin_thickness') }}">
                                @error('skin_thickness')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                        
                        <div class="row mb-4">
                            <div class="col-md-12">
                                <h4>Data Kesehatan</h4>
                            </div>
                            
                            <div class="col-md-3 mb-3">
                                <label for="bs" class="form-label">Gula Darah (mg/dL) <span class="text-danger">*</span></label>
                                <input type="number" step="0.01" class="form-control @error('bs') is-invalid @enderror" id="bs" name="bs" value="{{ old('bs') }}" required>
                                @error('bs')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                            
                            <div class="col-md-3 mb-3">
                                <label for="pregnancies" class="form-label">Jumlah Kehamilan <span class="text-danger">*</span></label>
                                <input type="number" class="form-control @error('pregnancies') is-invalid @enderror" id="pregnancies" name="pregnancies" value="{{ old('pregnancies', 0) }}" required>
                                @error('pregnancies')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                            
                            <div class="col-md-3 mb-3">
                                <label for="systolic_bp" class="form-label">Tekanan Sistolik</label>
                                <input type="number" class="form-control @error('systolic_bp') is-invalid @enderror" id="systolic_bp" name="systolic_bp" value="{{ old('systolic_bp') }}">
                                @error('systolic_bp')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                            
                            <div class="col-md-3 mb-3">
                                <label for="diastolic_bp" class="form-label">Tekanan Diastolik</label>
                                <input type="number" class="form-control @error('diastolic_bp') is-invalid @enderror" id="diastolic_bp" name="diastolic_bp" value="{{ old('diastolic_bp') }}">
                                @error('diastolic_bp')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                            
                            <div class="col-md-3 mb-3">
                                <label for="heart_rate" class="form-label">Detak Jantung</label>
                                <input type="number" class="form-control @error('heart_rate') is-invalid @enderror" id="heart_rate" name="heart_rate" value="{{ old('heart_rate') }}">
                                @error('heart_rate')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                            
                            <div class="col-md-3 mb-3">
                                <label for="body_temp" class="form-label">Suhu Tubuh (°C)</label>
                                <input type="number" step="0.1" class="form-control @error('body_temp') is-invalid @enderror" id="body_temp" name="body_temp" value="{{ old('body_temp') }}">
                                @error('body_temp')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                            
                            <div class="col-md-3 mb-3">
                                <label for="bp_meds" class="form-label">Konsumsi Obat Tekanan Darah</label>
                                <select class="form-select @error('bp_meds') is-invalid @enderror" id="bp_meds" name="bp_meds">
                                    <option value="">Pilih Opsi</option>
                                    <option value="1" {{ old('bp_meds') == '1' ? 'selected' : '' }}>Ya</option>
                                    <option value="0" {{ old('bp_meds') == '0' ? 'selected' : '' }}>Tidak</option>
                                </select>
                                @error('bp_meds')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                        
                        <div class="row mb-4">
                            <div class="col-md-12">
                                <h4>Informasi Gaya Hidup</h4>
                            </div>
                            
                            <div class="col-md-4 mb-3">
                                <label for="current_smoker" class="form-label">Status Merokok</label>
                                <select class="form-select @error('current_smoker') is-invalid @enderror" id="current_smoker" name="current_smoker">
                                    <option value="">Pilih Status</option>
                                    <option value="1" {{ old('current_smoker') == '1' ? 'selected' : '' }}>Ya</option>
                                    <option value="0" {{ old('current_smoker') == '0' ? 'selected' : '' }}>Tidak</option>
                                </select>
                                @error('current_smoker')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                            
                            <div class="col-md-4 mb-3">
                                <label for="cigs_per_day" class="form-label">Jumlah Rokok per Hari</label>
                                <input type="number" class="form-control @error('cigs_per_day') is-invalid @enderror" id="cigs_per_day" name="cigs_per_day" value="{{ old('cigs_per_day', 0) }}">
                                @error('cigs_per_day')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-12">
                                <div class="d-flex justify-content-between">
                                    <a href="{{ route('deteksi.index') }}" class="btn btn-secondary">Kembali</a>
                                    <button type="submit" class="btn btn-primary">Kirim</button>
                                </div>
                            </div>
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
    // Toggle cigars per day field based on smoker status
    document.addEventListener('DOMContentLoaded', function() {
        const smokerSelect = document.getElementById('current_smoker');
        const cigsPerDayField = document.getElementById('cigs_per_day');
        
        function toggleCigsPerDay() {
            const cigsPerDayContainer = cigsPerDayField.closest('.mb-3');
            if (smokerSelect.value === '1') {
                cigsPerDayContainer.style.display = 'block';
            } else {
                cigsPerDayContainer.style.display = 'none';
                cigsPerDayField.value = '0';
            }
        }
        
        // Initial state
        toggleCigsPerDay();
        
        // On change
        smokerSelect.addEventListener('change', toggleCigsPerDay);
    });
</script>
@endsection