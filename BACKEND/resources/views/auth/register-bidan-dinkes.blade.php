@extends('layouts.app')

@section('content')
<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h4 class="mb-0">Registrasi {{ request()->is('register/bidan') ? 'Bidan' : 'Dinas Kesehatan' }}</h4>
                </div>

                <div class="card-body">
                    <form method="POST" action="{{ route('register.process') }}" enctype="multipart/form-data">
                        @csrf
                        <input type="hidden" name="role" value="{{ request()->is('register/bidan') ? 'bidan' : 'dinas_kesehatan' }}">

                        <!-- Data Umum -->
                        <div class="mb-4">
                            <h5 class="border-bottom pb-2">Data Umum</h5>
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="name" class="form-label">Nama Pengguna*</label>
                                    <input id="name" type="text" class="form-control @error('name') is-invalid @enderror" name="name" value="{{ old('name') }}" required autocomplete="name" autofocus>
                                    @error('name')
                                        <span class="invalid-feedback" role="alert">
                                            <strong>{{ $message }}</strong>
                                        </span>
                                    @enderror
                                </div>

                                <div class="col-md-6 mb-3">
                                    <label for="email" class="form-label">Email*</label>
                                    <input id="email" type="email" class="form-control @error('email') is-invalid @enderror" name="email" value="{{ old('email') }}" required autocomplete="email">
                                    @error('email')
                                        <span class="invalid-feedback" role="alert">
                                            <strong>{{ $message }}</strong>
                                        </span>
                                    @enderror
                                </div>

                                <div class="col-md-6 mb-3">
                                    <label for="password" class="form-label">Password*</label>
                                    <input id="password" type="password" class="form-control @error('password') is-invalid @enderror" name="password" required autocomplete="new-password">
                                    @error('password')
                                        <span class="invalid-feedback" role="alert">
                                            <strong>{{ $message }}</strong>
                                        </span>
                                    @enderror
                                </div>

                                <div class="col-md-6 mb-3">
                                    <label for="password-confirm" class="form-label">Konfirmasi Password*</label>
                                    <input id="password-confirm" type="password" class="form-control" name="password_confirmation" required autocomplete="new-password">
                                </div>
                            </div>
                        </div>

                        @if(request()->is('register/bidan'))
                            <!-- Form Bidan -->
                            <div class="mb-4">
                                <h5 class="border-bottom pb-2">Data Profesional Bidan</h5>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="nama_lengkap" class="form-label">Nama Lengkap*</label>
                                        <input id="nama_lengkap" type="text" class="form-control @error('nama_lengkap') is-invalid @enderror" name="nama_lengkap" value="{{ old('nama_lengkap') }}" required>
                                        @error('nama_lengkap')
                                            <span class="invalid-feedback" role="alert">
                                                <strong>{{ $message }}</strong>
                                            </span>
                                        @enderror
                                    </div>

                                    <div class="col-md-6 mb-3">
                                        <label for="nik" class="form-label">NIK*</label>
                                        <input id="nik" type="text" class="form-control @error('nik') is-invalid @enderror" name="nik" value="{{ old('nik') }}" required>
                                        @error('nik')
                                            <span class="invalid-feedback" role="alert">
                                                <strong>{{ $message }}</strong>
                                            </span>
                                        @enderror
                                    </div>

                                    <!-- Tambahkan field lainnya untuk bidan -->
                                    <div class="col-md-6 mb-3">
                                        <label for="nomor_str" class="form-label">Nomor STR*</label>
                                        <input id="nomor_str" type="text" class="form-control @error('nomor_str') is-invalid @enderror" name="nomor_str" value="{{ old('nomor_str') }}" required>
                                        @error('nomor_str')
                                            <span class="invalid-feedback" role="alert">
                                                <strong>{{ $message }}</strong>
                                            </span>
                                        @enderror
                                    </div>

                                    <div class="col-md-6 mb-3">
                                        <label for="nomor_sipb" class="form-label">Nomor SIPB*</label>
                                        <input id="nomor_sipb" type="text" class="form-control @error('nomor_sipb') is-invalid @enderror" name="nomor_sipb" value="{{ old('nomor_sipb') }}" required>
                                        @error('nomor_sipb')
                                            <span class="invalid-feedback" role="alert">
                                                <strong>{{ $message }}</strong>
                                            </span>
                                        @enderror
                                    </div>

                                    <!-- Tambahkan field lainnya sesuai kebutuhan -->
                                </div>
                            </div>
                        @else
                            <!-- Form Dinas Kesehatan -->
                            <div class="mb-4">
                                <h5 class="border-bottom pb-2">Data Institusi</h5>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="nama_dinas" class="form-label">Nama Dinas Kesehatan*</label>
                                        <input id="nama_dinas" type="text" class="form-control @error('nama_dinas') is-invalid @enderror" name="nama_dinas" value="{{ old('nama_dinas') }}" required>
                                        @error('nama_dinas')
                                            <span class="invalid-feedback" role="alert">
                                                <strong>{{ $message }}</strong>
                                            </span>
                                        @enderror
                                    </div>

                                    <div class="col-md-6 mb-3">
                                        <label for="nama_admin" class="form-label">Nama Admin*</label>
                                        <input id="nama_admin" type="text" class="form-control @error('nama_admin') is-invalid @enderror" name="nama_admin" value="{{ old('nama_admin') }}" required>
                                        @error('nama_admin')
                                            <span class="invalid-feedback" role="alert">
                                                <strong>{{ $message }}</strong>
                                            </span>
                                        @enderror
                                    </div>

                                    <!-- Tambahkan field lainnya untuk dinas kesehatan -->
                                    <div class="col-12 mb-3">
                                        <label for="alamat_kantor" class="form-label">Alamat Kantor*</label>
                                        <textarea id="alamat_kantor" class="form-control @error('alamat_kantor') is-invalid @enderror" name="alamat_kantor" required>{{ old('alamat_kantor') }}</textarea>
                                        @error('alamat_kantor')
                                            <span class="invalid-feedback" role="alert">
                                                <strong>{{ $message }}</strong>
                                            </span>
                                        @enderror
                                    </div>

                                    <div class="col-md-6 mb-3">
                                        <label for="logo" class="form-label">Logo Institusi</label>
                                        <input id="logo" type="file" class="form-control @error('logo') is-invalid @enderror" name="logo">
                                        @error('logo')
                                            <span class="invalid-feedback" role="alert">
                                                <strong>{{ $message }}</strong>
                                            </span>
                                        @enderror
                                    </div>
                                </div>
                            </div>
                        @endif

                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-primary btn-lg">
                                Daftar Sekarang
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection