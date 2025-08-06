<?php

require __DIR__ . '/../vendor/autoload.php';

$app = require_once __DIR__ . '/../bootstrap/app.php';

$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

$request = Illuminate\Http\Request::capture();

$response = $kernel->handle($request);

$response->send();

$kernel->terminate($request, $response);

file_put_contents('/tmp/debug.log', 'Laravel started: ' . date('Y-m-d H:i:s') . PHP_EOL, FILE_APPEND);
