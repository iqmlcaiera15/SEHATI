<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Cetak Hasil Prediksi</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; line-height: 1.6; }
        h2 { color: #2c3e50; }
        p strong { width: 200px; display: inline-block; }
        .badge { padding: 4px 10px; border-radius: 4px; font-size: 14px; }
        hr { margin: 30px 0; }
    </style>
</head>
<body>
    <h2>Hasil Prediksi Metode Persalinan</h2>
    <p><strong>Nama Ibu:</strong> {{ $prediction->user->name ?? '-' }}</p>
    <p><strong>Metode:</strong> {{ ucfirst($prediction->metode_persalinan) }}</p>
    <p><strong>Faktor Penentu:</strong>
        {{ is_array($prediction->faktor) ? implode(', ', $prediction->faktor) : $prediction->faktor ?? '-' }}
    </p>
    <p><strong>Usia Ibu:</strong> {{ $prediction->usia_ibu }} tahun</p>
    <p><strong>Tekanan Darah:</strong> {{ ucfirst($prediction->tekanan_darah) }}</p>
    <p><strong>Riwayat Persalinan:</strong> {{ ucfirst($prediction->riwayat_persalinan) }}</p>
    <p><strong>Posisi Janin:</strong> {{ ucfirst($prediction->posisi_janin) }}</p>
    <p><strong>Kondisi Janin:</strong> {{ ucfirst($prediction->kondisi_kesehatan_janin) }}</p>
    <p><strong>Riwayat Kesehatan Ibu:</strong> {{ ucfirst($prediction->riwayat_kesehatan_ibu) }}</p>
    <hr>
    <p>Dicetak pada: {{ \Carbon\Carbon::now('Asia/Jakarta')->format('d M Y, H:i') }}</p>
</body>
</html>
