@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">{{ __('Register Bidan') }}</div>

                <div class="card-body">
                    <form method="POST" action="{{ route('register.bidan') }}">
                        @csrf

                        <div class="row mb-3">
                            <label for="name" class="col-md-4 col-form-label text-md-end">{{ __('Name') }}</label>

                            <div class="col-md-6">
                                <input id="name" type="text" class="form-control @error('name') is-invalid @enderror" name="name" value="{{ old('name') }}" required autocomplete="name" autofocus>

                                @error('name')
                                    <span class="invalid-feedback" role="alert">
                                        <strong>{{ $message }}</strong>
                                    </span>
                                @enderror
                            </div>
                        </div>

                        <div class="row mb-3">
                            <label for="email" class="col-md-4 col-form-label text-md-end">{{ __('Email Address') }}</label>

                            <div class="col-md-6">
                                <input id="email" type="email" class="form-control @error('email') is-invalid @enderror" name="email" value="{{ old('email') }}" required autocomplete="email">

                                @error('email')
                                    <span class="invalid-feedback" role="alert">
                                        <strong>{{ $message }}</strong>
                                    </span>
                                @enderror
                            </div>
                        </div>

                        <div class="row mb-3">
                            <label for="password" class="col-md-4 col-form-label text-md-end">{{ __('Password') }}</label>

                            <div class="col-md-6">
                                <input id="password" type="password" class="form-control @error('password') is-invalid @enderror" name="password" required autocomplete="new-password">

                                @error('password')
                                    <span class="invalid-feedback" role="alert">
                                        <strong>{{ $message }}</strong>
                                    </span>
                                @enderror
                            </div>
                        </div>

                        <div class="row mb-3">
                            <label for="password-confirm" class="col-md-4 col-form-label text-md-end">{{ __('Confirm Password') }}</label>

                            <div class="col-md-6">
                                <input id="password-confirm" type="password" class="form-control" name="password_confirmation" required autocomplete="new-password">
                            </div>
                        </div>

                        <!-- BIDAN Specific Fields -->
                        <hr>
                        <h5>Informasi Bidan</h5>

                        <div class="row mb-3">
                            <label for="nomor_str" class="col-md-4 col-form-label text-md-end">{{ __('Nomor STR') }}</label>
                            <div class="col-md-6">
                                <input id="nomor_str" type="text" class="form-control @error('nomor_str') is-invalid @enderror" name="nomor_str" value="{{ old('nomor_str') }}" required>
                                @error('nomor_str')
                                    <span class="invalid-feedback" role="alert">
                                        <strong>{{ $message }}</strong>
                                    </span>
                                @enderror
                            </div>
                        </div>

                        <div class="row mb-3">
                            <label for="masa_berlaku_str" class="col-md-4 col-form-label text-md-end">{{ __('Masa Berlaku STR') }}</label>
                            <div class="col-md-6">
                                <input id="masa_berlaku_str" type="date" class="form-control @error('masa_berlaku_str') is-invalid @enderror" name="masa_berlaku_str" value="{{ old('masa_berlaku_str') }}" required>
                                @error('masa_berlaku_str')
                                    <span class="invalid-feedback" role="alert">
                                        <strong>{{ $message }}</strong>
                                    </span>
                                @enderror
                            </div>
                        </div>

                        <div class="row mb-3">
                            <label for="nomor_sipb" class="col-md-4 col-form-label text-md-end">{{ __('Nomor SIPB') }}</label>
                            <div class="col-md-6">
                                <input id="nomor_sipb" type="text" class="form-control @error('nomor_sipb') is-invalid @enderror" name="nomor_sipb" value="{{ old('nomor_sipb') }}" required>
                                @error('nomor_sipb')
                                    <span class="invalid-feedback" role="alert">
                                        <strong>{{ $message }}</strong>
                                    </span>
                                @enderror
                            </div>
                        </div>

                        <div class="row mb-3">
                            <label for="masa_berlaku_sipb" class="col-md-4 col-form-label text-md-end">{{ __('Masa Berlaku SIPB') }}</label>
                            <div class="col-md-6">
                                <input id="masa_berlaku_sipb" type="date" class="form-control @error('masa_berlaku_sipb') is-invalid @enderror" name="masa_berlaku_sipb" value="{{ old('masa_berlaku_sipb') }}" required>
                                @error('masa_berlaku_sipb')
                                    <span class="invalid-feedback" role="alert">
                                        <strong>{{ $message }}</strong>
                                    </span>
                                @enderror
                            </div>
                        </div>

                        <div class="row mb-3">
                            <label for="tempat_praktik" class="col-md-4 col-form-label text-md-end">{{ __('Tempat Praktik') }}</label>
                            <div class="col-md-6">
                                <input id="tempat_praktik" type="text" class="form-control @error('tempat_praktik') is-invalid @enderror" name="tempat_praktik" value="{{ old('tempat_praktik') }}" required>
                                @error('tempat_praktik')
                                    <span class="invalid-feedback" role="alert">
                                        <strong>{{ $message }}</strong>
                                    </span>
                                @enderror
                            </div>
                        </div>

                        <div class="row mb-3">
                            <label for="alamat_praktik" class="col-md-4 col-form-label text-md-end">{{ __('Alamat Praktik') }}</label>
                            <div class="col-md-6">
                                <textarea id="alamat_praktik" class="form-control @error('alamat_praktik') is-invalid @enderror" name="alamat_praktik" required>{{ old('alamat_praktik') }}</textarea>
                                @error('alamat_praktik')
                                    <span class="invalid-feedback" role="alert">
                                        <strong>{{ $message }}</strong>
                                    </span>
                                @enderror
                            </div>
                        </div>

                        <div class="row mb-3">
                            <label for="telepon_tempat_praktik" class="col-md-4 col-form-label text-md-end">{{ __('Telepon Tempat Praktik') }}</label>
                            <div class="col-md-6">
                                <input id="telepon_tempat_praktik" type="text" class="form-control @error('telepon_tempat_praktik') is-invalid @enderror" name="telepon_tempat_praktik" value="{{ old('telepon_tempat_praktik') }}" required>
                                @error('telepon_tempat_praktik')
                                    <span class="invalid-feedback" role="alert">
                                        <strong>{{ $message }}</strong>
                                    </span>
                                @enderror
                            </div>
                        </div>

                        <div class="row mb-3">
                            <label for="spesialisasi" class="col-md-4 col-form-label text-md-end">{{ __('Spesialisasi') }}</label>
                            <div class="col-md-6">
                                <input id="spesialisasi" type="text" class="form-control @error('spesialisasi') is-invalid @enderror" name="spesialisasi" value="{{ old('spesialisasi') }}" required>
                                @error('spesialisasi')
                                    <span class="invalid-feedback" role="alert">
                                        <strong>{{ $message }}</strong>
                                    </span>
                                @enderror
                            </div>
                        </div>

                        <div class="row mb-3">
                            <label for="nik" class="col-md-4 col-form-label text-md-end">{{ __('NIK') }}</label>
                            <div class="col-md-6">
                                <input id="nik" type="text" class="form-control @error('nik') is-invalid @enderror" name="nik" value="{{ old('nik') }}" required>
                                @error('nik')
                                    <span class="invalid-feedback" role="alert">
                                        <strong>{{ $message }}</strong>
                                    </span>
                                @enderror
                            </div>
                        </div>

                        <div class="row mb-0">
                            <div class="col-md-6 offset-md-4">
                                <button type="submit" class="btn btn-primary">
                                    {{ __('Register') }}
                                </button>
                                <a href="{{ route('login') }}" class="btn btn-link">
                                    {{ __('Already have an account? Login') }}
                                </a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

