<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PrediksiDepresi extends Model
{
    use HasFactory;

    protected $table = 'prediksi_depresi';
    protected $fillable = [
        'umur',
        'merasa_sedih',
        'mudah_tersinggung',
        'masalah_tidur',
        'masalah_fokus',
        'pola_makan',
        'merasa_bersalah',
        'suicide_attempt',
        'hasil_prediksi'
    ];

    # Convert Text
    
    public function getMerasaSedihAttribute($value)
    {
        return $this->convertText('merasa_sedih', $value);
    }

    public function getMudahTersinggungAttribute($value)
    {
        return $this->convertText('mudah_tersinggung', $value);
    }

    public function getMasalahTidurAttribute($value)
    {
        return $this->convertText('masalah_tidur', $value);
    }

    public function getMasalahFokusAttribute($value)
    {
        return $this->convertText('masalah_fokus', $value);
    }

    public function getPolaMakanAttribute($value)
    {
        return $this->convertText('pola_makan', $value);
    }

    public function getMerasaBersalahAttribute($value)
    {
        return $this->convertText('merasa_bersalah', $value);
    }

    public function getSuicideAttemptAttribute($value)
    {
        return $this->convertText('suicide_attempt', $value);
    }

    # Convert Number
    
    public function setMerasaSedihAttribute($value)
    {
        $this->attributes['merasa_sedih'] = $this->convertNumber('merasa_sedih', $value);
    }

    public function setMudahTersinggungAttribute($value)
    {
        $this->attributes['mudah_tersinggung'] = $this->convertNumber('mudah_tersinggung', $value);
    }

    public function setMasalahTidurAttribute($value)
    {
        $this->attributes['masalah_tidur'] = $this->convertNumber('masalah_tidur', $value);
    }

    public function setMasalahFokusAttribute($value)
    {
        $this->attributes['masalah_fokus'] = $this->convertNumber('masalah_fokus', $value);
    }

    public function setPolaMakanAttribute($value)
    {
        $this->attributes['pola_makan'] = $this->convertNumber('pola_makan', $value);
    }

    public function setMerasaBersalahAttribute($value)
    {
        $this->attributes['merasa_bersalah'] = $this->convertNumber('merasa_bersalah', $value);
    }

    public function setSuicideAttemptAttribute($value)
    {
        $this->attributes['suicide_attempt'] = $this->convertNumber('suicide_attempt', $value);
    }
    
    private function convertText($field, $value)
    {
        $mapping = [
            'merasa_sedih' => [0 => 'Tidak', 1 => 'Kadang-kadang', 2 => 'Ya'],
            'mudah_tersinggung' => [0 => 'Tidak', 1 => 'Kadang-kadang', 2 => 'Ya'],
            'masalah_tidur' => [0 => 'Tidak', 1 => 'Dua hari dalam seminggu/lebih', 2 => 'Ya'],
            'masalah_fokus' => [0 => 'Tidak', 1 => 'Ya', 2 => 'Sering'],
            'pola_makan' => [0 => 'Tidak sama sekali', 1 => 'Kadang-kadang', 2 => 'Ya'],
            'merasa_bersalah' => [0 => 'Tidak', 1 => 'Mungkin', 2 => 'Ya'],
            'suicide_attempt' => [0 => 'Tidak', 1 => 'Ya', 2 => 'Tidak ingin menjawab'],
        ];

        return $mapping[$field][$value] ?? 'Tidak diketahui';
    }

    private function convertNumber($field, $value)
    {
        $mapping = [
            'merasa_sedih' => ['Tidak' => 0, 'Kadang-kadang' => 1, 'Ya' => 2],
            'mudah_tersinggung' => ['Tidak' => 0, 'Kadang-kadang' => 1, 'Ya' => 2],
            'masalah_tidur' => ['Tidak' => 0, 'Dua hari dalam seminggu/lebih' => 1, 'Ya' => 2],
            'masalah_fokus' => ['Tidak' => 0, 'Ya' => 1, 'Sering' => 2],
            'pola_makan' => ['Tidak sama sekali' => 0, 'Kadang-kadang' => 1, 'Ya' => 2],
            'merasa_bersalah' => ['Tidak' => 0, 'Mungkin' => 1, 'Ya' => 2],
            'suicide_attempt' => ['Tidak' => 0, 'Ya' => 1, 'Tidak ingin menjawab' => 2],
        ];

        return $mapping[$field][$value] ?? null;
    }
}
