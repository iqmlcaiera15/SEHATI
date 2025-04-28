<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Laravel CORS Options
    |--------------------------------------------------------------------------
    |
    | The allowed origins, methods, and headers for cross-origin requests.
    |
    */
    'supports_credentials' => false,

    'allowed_origins' => ['*'],  // Mengizinkan semua domain (Anda bisa mengganti dengan domain tertentu jika ingin lebih ketat)
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],  // Mengizinkan semua header
    'allowed_methods' => ['*'],  // Mengizinkan semua metode (GET, POST, PUT, DELETE, dll.)
    'exposed_headers' => [],
    'max_age' => 0,
    'hosts' => [],
];
