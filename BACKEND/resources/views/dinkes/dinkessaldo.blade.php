@extends('layouts.app')

@section('title', 'Pengelolaan Saldo Ibu Hamil')

@section('content')
<div class="container-fluid">
    <!-- Page Heading -->
    <div class="d-sm-flex align-items-center justify-content-between mb-4">
        <h1 class="h3 mb-0 text-gray-800">Pengelolaan Saldo Ibu Hamil</h1>
    </div>

    <!-- Content Row -->
    <div class="row">
        <div class="col-12">
            <div class="card shadow mb-4">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h6 class="m-0 font-weight-bold text-primary">Daftar Ibu Hamil</h6>
                    <div class="dropdown no-arrow">
                        <a href="{{ route('admin.saldo.laporan') }}" class="btn btn-sm btn-primary shadow-sm">
                            <i class="fas fa-file-alt fa-sm text-white-50"></i> Laporan Transaksi
                        </a>
                    </div>
                </div>
                <div class="card-body">
                    <!-- Filter Form -->
                    <form action="{{ route('admin.saldo.index') }}" method="GET" class="mb-4">
                        <div class="row">
                            <div class="col-md-5">
                                <div class="form-group">
                                    <label for="Nama">Nama Ibu</label>
                                    <input type="text" class="form-control" id="nama" name="nama" value="{{ request('nama') }}" placeholder="Cari berdasarkan nama">
                                </div>
                            </div>
                            <div class="col-md-5">
                                <div class="form-group">
                                    <label for="Usia">Kelurahan/Desa</label>
                                    <input type="text" class="form-control" id="usia" name="usia" value="{{ request('usia') }}" placeholder="Cari berdasarkan kelurahan/desa">
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label class="d-block">&nbsp;</label>
                                    <button type="submit" class="btn btn-primary btn-block">Filter</button>
                                </div>
                            </div>
                        </div>
                    </form>

                    <!-- Table -->
                    <div class="table-responsive">
                        <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                            <thead>
                                <tr>
                                    <th width="5%">No</th>
                                    <th>Nama Ibu</th>
                                    <th>NIK</th>
                                    <th>Alamat</th>
                                    <th>Kelurahan</th>
                                    <th>Kecamatan</th>
                                    <th>Saldo Total</th>
                                    <th width="15%">Aksi</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse($ibuHamil as $key => $ibu)
                                <tr>
                                    <td>{{ $ibuHamil->firstItem() + $key }}</td>
                                    <td>{{ $ibu->nama }}</td>
                                    <td>{{ $ibu->usia }}</td>
                                    <td>{{ $ibu->alamat }}</td>
                                    <td>{{ $ibu->pekerjaan }}</td>
                                    <td>{{ $ibu->tanggal_lahir }}</td>
                                    <td>Rp {{ number_format($ibu->saldo_total, 0, ',', '.') }}</td>
                                    <td>
                                        <button type="button" class="btn btn-sm btn-success tambah-saldo" 
                                                data-toggle="modal" data-target="#tambahSaldoModal" 
                                                data-id="{{ $ibu->id }}" 
                                                data-nama="{{ $ibu->nama }}">
                                            <i class="fas fa-plus-circle"></i> Tambah
                                        </button>
                                        <a href="{{ route('admin.saldo.riwayat', $ibu->id) }}" class="btn btn-sm btn-info">
                                            <i class="fas fa-history"></i> Riwayat
                                        </a>
                                    </td>
                                </tr>
                                @empty
                                <tr>
                                    <td colspan="8" class="text-center">Tidak ada data</td>
                                </tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <div class="d-flex justify-content-end mt-3">
                        {{ $ibuHamil->links() }}
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Tambah Saldo Modal -->
<div class="modal fade" id="tambahSaldoModal" tabindex="-1" role="dialog" aria-labelledby="tambahSaldoModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="tambahSaldoModalLabel">Tambah Saldo</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <form id="formTambahSaldo" action="{{ route('admin.saldo.tambah') }}" method="POST">
                @csrf
                <div class="modal-body">
                    <input type="hidden" name="user_id" id="user_id">
                    <div class="form-group">
                        <label>Nama Ibu</label>
                        <input type="text" class="form-control" id="nama_ibu" readonly>
                    </div>
                    <div class="form-group">
                        <label for="jumlah">Jumlah Saldo (Rp)</label>
                        <input type="number" class="form-control" id="jumlah" name="jumlah" required min="1">
                    </div>
                    <div class="form-group">
                        <label for="keterangan">Keterangan</label>
                        <textarea class="form-control" id="keterangan" name="keterangan" rows="3"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Batal</button>
                    <button type="submit" class="btn btn-primary">Simpan</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
    $(document).ready(function() {
        // Set data to modal when clicking "Tambah Saldo" button
        $('.tambah-saldo').on('click', function() {
            const userId = $(this).data('id');
            const namaIbu = $(this).data('nama');
            
            $('#user_id').val(userId);
            $('#nama_ibu').val(namaIbu);
            $('#jumlah').val('');
            $('#keterangan').val('');
        });
        
        // Form validation and submission using AJAX
        $('#formTambahSaldo').submit(function(e) {
            e.preventDefault();
            
            const form = $(this);
            const url = form.attr('action');
            
            $.ajax({
                type: "POST",
                url: url,
                data: form.serialize(),
                success: function(response) {
                    if (response.status) {
                        // Show success message
                        Swal.fire({
                            title: 'Berhasil!',
                            text: response.message,
                            icon: 'success',
                            confirmButtonText: 'OK'
                        }).then((result) => {
                            // Refresh page after success
                            location.reload();
                        });
                    } else {
                        // Show error message
                        Swal.fire({
                            title: 'Gagal!',
                            text: response.message,
                            icon: 'error',
                            confirmButtonText: 'OK'
                        });
                    }
                },
                error: function(xhr) {
                    // Handle validation errors
                    if (xhr.status === 422) {
                        const errors = xhr.responseJSON.errors;
                        let errorMessage = '';
                        
                        $.each(errors, function(key, value) {
                            errorMessage += value[0] + '<br>';
                        });
                        
                        Swal.fire({
                            title: 'Validasi Gagal!',
                            html: errorMessage,
                            icon: 'error',
                            confirmButtonText: 'OK'
                        });
                    } else {
                        // Handle other errors
                        Swal.fire({
                            title: 'Error!',
                            text: 'Terjadi kesalahan pada server',
                            icon: 'error',
                            confirmButtonText: 'OK'
                        });
                    }
                }
            });
        });
    });
</script>
@endpush