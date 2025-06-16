@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h3>Riwayat Deteksi Penyakit</h3>
                    <div>
                        <a href="{{ route('deteksi.create') }}" class="btn btn-primary">Deteksi Baru</a>
                        
                        @if(count($deteksiPenyakit) > 0)
                        <button type="button" class="btn btn-danger" data-bs-toggle="modal" data-bs-target="#deleteAllModal">
                            Hapus Semua
                        </button>
                        @endif
                    </div>
                </div>

                <div class="card-body">
                    @if(session('success'))
                        <div class="alert alert-success">
                            {{ session('success') }}
                        </div>
                    @endif
                    
                    @if(session('error'))
                        <div class="alert alert-danger">
                            {{ session('error') }}
                        </div>
                    @endif
                    
                    @if(count($deteksiPenyakit) > 0)
                        <div class="table-responsive">
                            <table class="table table-striped">
                                <thead>
                                    <tr>
                                        <th>Nama</th>
                                        <th>Umur</th>
                                        <th>BMI</th>
                                        <th>Hasil Diabetes</th>
                                        <th>Hasil Hipertensi</th>
                                        <th>Hasil Kesehatan Maternal</th>
                                        <th>Tanggal</th>
                                        <th>Aksi</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach($deteksiPenyakit as $deteksi)
                                    <tr>
                                        <td>{{ $deteksi->nama }}</td>
                                        <td>{{ $deteksi->age }} tahun</td>
                                        <td>{{ $deteksi->bmi }}</td>
                                        <td>
                                            @if($deteksi->diabetes_prediction == 1)
                                                <span class="badge bg-danger">Positif</span>
                                            @else
                                                <span class="badge bg-success">Negatif</span>
                                            @endif
                                        </td>
                                        <td>
                                            @if($deteksi->hypertension_prediction == 1)
                                                <span class="badge bg-danger">Positif</span>
                                            @else
                                                <span class="badge bg-success">Negatif</span>
                                            @endif
                                        </td>
                                        <td>
                                            @if($deteksi->maternal_health_prediction == 'low risk' )
                                                <span class="badge bg-success">Normal</span>
                                            @elseif($deteksi->maternal_health_prediction == 'medium risk')
                                                <span class="badge bg-warning">Risiko Rendah</span>
                                            @else
                                                <span class="badge bg-danger">High Risk</span>
                                            @endif
                                        </td>
                                        <td>{{ $deteksi->created_at->format('d M Y H:i') }}</td>
                                        <td>
                                            <a href="{{ route('deteksi.show', $deteksi->deteksi_id) }}" class="btn btn-sm btn-info">Detail</a>
                                            <button type="button" class="btn btn-sm btn-danger" data-bs-toggle="modal" data-bs-target="#deleteModal{{ $deteksi->id }}">
                                                Hapus
                                            </button>
                                        </td>
                                    </tr>
                                    
                                    <!-- Delete Modal -->
                                    <div class="modal fade" id="deleteModal{{ $deteksi->deteksi_id }}" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
                                      <div class="modal-dialog">
                                        <div class="modal-content">
                                          <div class="modal-header">
                                            <h5 class="modal-title" id="deleteModalLabel">Konfirmasi Hapus</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                          </div>
                                          <div class="modal-body">
                                            Apakah Anda yakin ingin menghapus data deteksi untuk "{{ $deteksi->nama }}"?
                                          </div>
                                          <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                                            <form action="{{ route('deteksi.destroy', $deteksi->deteksi_id) }}" method="POST">
                                                @csrf
                                                @method('DELETE')
                                                <button type="submit" class="btn btn-danger">Hapus</button>
                                            </form>
                                          </div>
                                        </div>
                                      </div>
                                    </div>
                                    @endforeach
                                </tbody>
                            </table>
                        </div>
                    @else
                        <div class="alert alert-info">
                            Belum ada data deteksi penyakit. 
                            <a href="{{ route('deteksi.create') }}" class="alert-link">Buat deteksi baru</a>.
                        </div>
                    @endif
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Delete All Modal -->
<div class="modal fade" id="deleteAllModal" tabindex="-1" aria-labelledby="deleteAllModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="deleteAllModalLabel">Konfirmasi Hapus Semua</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        Apakah Anda yakin ingin menghapus semua data deteksi?
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
        <a href="{{ route('deteksi.deleteAll') }}" class="btn btn-danger">Hapus Semua</a>
      </div>
    </div>
  </div>
</div>
@endsection