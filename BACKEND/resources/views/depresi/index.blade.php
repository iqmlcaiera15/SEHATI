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
                <option value="bergejala" {{ request('hasil') == 'bergejala' ? 'selected' : '' }}>Bergejala Depresi</option>
                <option value="tidak_bergejala" {{ request('hasil') == 'tidak_bergejala' ? 'selected' : '' }}>Tidak Bergejala Depresi</option>
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
                            $finalResult = false;
                            $hasilText = 'Tidak Bergejala Depresi';
                            $badgeClass = 'bg-success';
                            
                            if ($data->hasil_prediksi == 1) {
                                // Kondisi: Jika hasil prediksi = 1 maka bergejala depresi
                                $finalResult = true;
                                $hasilText = 'Bergejala Depresi';
                                $badgeClass = 'bg-danger';
                            } elseif ($data->hasil_prediksi == 0) {
                                if ($data->epds && $data->epds->score >= 12) {
                                    // Kondisi: Jika hasil prediksi = 0 tapi skor EPDS >= 12 maka bergejala depresi
                                    $finalResult = true;
                                    $hasilText = 'Bergejala Depresi';
                                    $badgeClass = 'bg-danger';
                                } else {
                                    // Kondisi: Jika hasil prediksi = 0 dan (tidak ada EPDS atau skor EPDS < 12) maka tidak bergejala
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