@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h3>Riwayat Prediksi Depresi</h3>
                    <div>
                        <a href="{{ route('depresi.create') }}" class="btn btn-primary">Prediksi Baru</a>
                        
                        @if($prediksiList->count() > 0)
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

                    <!-- Filter Section -->
                    <form method="GET" class="row g-3 mb-4">
                        <div class="col-md-4">
                            <label class="form-label">Filter Tanggal</label>
                            <input type="date" name="tanggal" class="form-control" value="{{ request('tanggal') }}">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Filter Hasil</label>
                            <select name="hasil" class="form-control">
                                <option value="">-- Semua --</option>
                                <option value="bergejala" {{ request('hasil') == 'bergejala' ? 'selected' : '' }}>Bergejala Depresi</option>
                                <option value="tidak_bergejala" {{ request('hasil') == 'tidak_bergejala' ? 'selected' : '' }}>Tidak Bergejala Depresi</option>
                            </select>
                        </div>
                        <div class="col-md-4 align-self-end">
                            <button type="submit" class="btn btn-primary w-100">Filter</button>
                        </div>
                    </form>
                    
                    @if($prediksiList->count() > 0)
                        <div class="table-responsive">
                            <table class="table table-striped">
                                <thead>
                                    <tr>
                                        <th>Nama</th>
                                        <th>Umur</th>
                                        <th>Hasil</th>
                                        <th>Gejala</th>
                                        <th>Skor EPDS</th>
                                        <th>Tanggal</th>
                                        <th>Aksi</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach($prediksiList as $data)
                                    <tr>
                                        <td>{{ $data->user->name ?? '-' }}</td>
                                        <td>{{ $data->user->usia ?? '-' }} tahun</td>
                                        <td>
                                            @php
                                                $finalResult = false;
                                                $hasilText = 'Tidak Bergejala Depresi';
                                                $badgeClass = 'bg-success';
                                                
                                                // Logika berdasarkan hasil prediksi dan skor EPDS
                                                if ($data->hasil_prediksi == 1) {
                                                    if ($data->epds && $data->epds->score >= 13) {
                                                        $finalResult = true;
                                                        $hasilText = 'Resiko Tinggi Depresi';
                                                        $badgeClass = 'bg-danger';
                                                    } elseif ($data->epds && $data->epds->score >= 10) {
                                                        $finalResult = true;
                                                        $hasilText = 'Kemungkinan Gejala Depresi';
                                                        $badgeClass = 'bg-warning';
                                                    } else {
                                                        $finalResult = false;
                                                        $hasilText = 'Tidak Bergejala Depresi';
                                                        $badgeClass = 'bg-success';
                                                    }
                                                } elseif ($data->hasil_prediksi == 0) {
                                                    if ($data->epds && $data->epds->score >= 13) {
                                                        $finalResult = true;
                                                        $hasilText = 'Resiko Tinggi Depresi';
                                                        $badgeClass = 'bg-danger';
                                                    } elseif ($data->epds && $data->epds->score >= 10) {
                                                        $finalResult = true;
                                                        $hasilText = 'Kemungkinan Gejala Depresi';
                                                        $badgeClass = 'bg-warning';
                                                    } else {
                                                        $finalResult = false;
                                                        $hasilText = 'Tidak Bergejala Depresi';
                                                        $badgeClass = 'bg-success';
                                                    }
                                                }
                                            @endphp
                                            <span class="badge {{ $badgeClass }}">
                                                {{ $hasilText }}
                                            </span>
                                        </td>
                                        <td>
                                            <ul class="mb-0 ps-3 small">
                                                <li>Merasa Sedih: {{ $data->getMerasaSedihTextAttribute()}}</li>
                                                <li>Mudah Tersinggung: {{ $data->getMudahTersinggungTextAttribute() }}</li>
                                                <li>Masalah Tidur: {{ $data->getMasalahTidurTextAttribute()}}</li>
                                                <li>Masalah Fokus: {{ $data->getMasalahFokusTextAttribute()}}</li>
                                                <li>Pola Makan: {{ $data->getPolaMakanTextAttribute() }}</li>
                                            </ul>
                                        </td>
                                        <td>{{ $data->epds?->score ?? '-' }}</td>
                                        <td>{{ $data->created_at->format('d M Y H:i') }}</td>
                                        <td>
                                            <a href="{{ route('depresi.show', $data->id) }}" class="btn btn-sm btn-info">Detail</a>
                                            <button type="button" class="btn btn-sm btn-danger" data-bs-toggle="modal" data-bs-target="#deleteModal{{ $data->id }}">
                                                Hapus
                                            </button>
                                        </td>
                                    </tr>
                                    
                                    <!-- Delete Modal -->
                                    <div class="modal fade" id="deleteModal{{ $data->id }}" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
                                      <div class="modal-dialog">
                                        <div class="modal-content">
                                          <div class="modal-header">
                                            <h5 class="modal-title" id="deleteModalLabel">Konfirmasi Hapus</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                          </div>
                                          <div class="modal-body">
                                            Apakah Anda yakin ingin menghapus data prediksi untuk "{{ $data->user->name ?? 'User' }}"?
                                          </div>
                                          <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                                            <form action="{{ route('depresi.destroy', $data->id) }}" method="POST">
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
                        
                        <!-- Pagination -->
                        <div class="d-flex justify-content-center">
                            {{ $prediksiList->links() }}
                        </div>
                    @else
                        <div class="alert alert-info">
                            Belum ada data prediksi depresi. 
                            <a href="{{ route('depresi.create') }}" class="alert-link">Buat prediksi baru</a>.
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
        Apakah Anda yakin ingin menghapus semua data prediksi depresi?
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
        <a href="{{ route('depresi.deleteAll') }}" class="btn btn-danger">Hapus Semua</a>
      </div>
    </div>
  </div>
</div>
@endsection
