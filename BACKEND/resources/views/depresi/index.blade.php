@extends('layouts.app')
@section('content')
<div class="container">
    <h3 class="mb-4">Riwayat Prediksi Depresi</h3>
    <!-- Filter -->
    <form method="GET" class="row g-3 mb-4">
        <div class="col-md-4">
            <label>Filter Tanggal</label>
            <input type="date" name="tanggal" class="form-control" value="{{ request('tanggal') }}">
        </div>
        <div class="col-md-4">
            <label>Filter Hasil</label>
            <select name="hasil" class="form-control">
                <option value="">-- Semua --</option>
                <option value="bergejala" {{ request('hasil_prediksi') == '1' ? 'selected' : '' }}>Bergejala Depresi</option>
                <option value="tidak_bergejala" {{ request('hasil_prediksi') == '0' ? 'selected' : '' }}>Tidak Bergejala Depresi</option>
            </select>
        </div>
        <div class="col-md-4 align-self-end">
            <button type="submit" class="btn btn-primary w-100">Filter</button>
        </div>
    </form>
    @if(session('success'))
        <div class="alert alert-success">{{ session('success') }}</div>
    @endif
    @if($prediksiList->count() > 0)
    <div class="table-responsive">
        <table class="table table-striped align-middle">
            <thead>
                <tr>
                    <th>Nama</th>
                    <th>Umur</th>
                    <th>Tanggal</th>
                    <th>Hasil</th>
                    <th>Gejala</th>
                    <th>Skor EPDS</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                @foreach($prediksiList as $data)
                <tr>
                    <td>{{ $data->user->name ?? '-' }}</td>
                    <td>{{ $data->user->usia ?? '-' }}</td>
                    <td>{{ $data->created_at->format('d M Y H:i') }}</td>
                    <td>
                        @php
                            // Logika sesuai kondisi yang diminta
                            $hasilText = '';
                            $badgeClass = '';
                            
                            if ($data->hasil_prediksi == 1) {
                                // Kondisi 4: Jika hasil prediksi = 1 maka akan muncul 'Bergejala Depresi'
                                $hasilText = 'Bergejala Depresi';
                                $badgeClass = 'bg-danger';
                            } else if ($data->hasil_prediksi == 0) {
                                if ($data->epds && $data->epds->score >= 12) {
                                    // Kondisi 3: Jika hasil prediksi = 0 tapi ada skor epds dengan skor >= 12 maka hasil prediksi akan muncul 'Bergejala Depresi'
                                    $hasilText = 'Bergejala Depresi';
                                    $badgeClass = 'bg-danger';
                                } else {
                                    // Kondisi 1 & 2: Jika hasil prediksi = 0 tapi ada skor epds dengan skor <12 atau tidak ada skor epds = 'Tidak bergejala depresi'
                                    $hasilText = 'Tidak bergejala depresi';
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
                    <td>
                        {{ $data->epds?->score ?? '-' }}
                    </td>
                    <td>
                        <a href="{{ route('depresi.show', $data->id) }}" class="btn btn-sm btn-info">Detail</a>
                        <form action="{{ route('depresi.destroy', $data->id) }}" method="POST" class="d-inline"
                              onsubmit="return confirm('Yakin ingin menghapus data ini?')">
                            @csrf @method('DELETE')
                            <button class="btn btn-sm btn-danger">Hapus</button>
                        </form>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
    {{ $prediksiList->links() }}
    @else
        <div class="alert alert-info">Belum ada data prediksi depresi.</div>
    @endif
</div>
@endsection