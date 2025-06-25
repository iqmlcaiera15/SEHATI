<!-- Form Card -->
<div class="row justify-content-center">
    <div class="col-lg-8 col-md-10 mx-auto">
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
                                <select id="user_id" name="user_id" class="form-select custom-input" required>
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
                            <input type="number" id="usia_ibu" name="usia_ibu" class="form-control custom-input" min="15" max="50"
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
                            <select id="tekanan_darah" name="tekanan_darah" class="form-select custom-input" required>
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
                            <select id="riwayat_persalinan" name="riwayat_persalinan" class="form-select custom-input" required>
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
                            <select id="posisi_janin" name="posisi_janin" class="form-select custom-input" required>
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
                            <input type="text" id="riwayat_kesehatan_ibu" name="riwayat_kesehatan_ibu" class="form-control custom-input"
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
                            <input type="text" id="kondisi_kesehatan_janin" name="kondisi_kesehatan_janin" class="form-control custom-input"
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
                    <div class="row mt-4">
                        <div class="col-12 text-center">
                            <button type="submit" class="btn btn-gradient-main px-5 py-2 fw-bold d-inline-flex align-items-center gap-2 shadow-sm rounded-3"
                                style="font-size: 1.13rem;">
                                <i class="fas fa-check-circle me-2"></i>
                                Prediksi Sekarang
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
