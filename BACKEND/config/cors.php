<?php

return [

    'paths' => ['api/*', '*'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'],  // Bisa diganti dengan domain frontend tertentu
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 3600,  // Setel preflight request cache selama 1 jam
    'supports_credentials' => false, // Ganti ke true jika diperlukan untuk cookie/authorization header

];
