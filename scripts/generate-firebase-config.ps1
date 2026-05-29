#!/usr/bin/env pwsh

# Este script genera google-services.json desde google-services.json.template
# Inyecta variables de entorno en el archivo

$templatePath = "android/app/google-services.json.template"
$outputPath = "android/app/google-services.json"
$envFile = ".env.local"

# Cargar variables de .env.local si existe
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^=]+)=(.+)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim().Trim('"')
            [Environment]::SetEnvironmentVariable($key, $value, [System.EnvironmentVariableTarget]::Process)
        }
    }
    Write-Host "✅ Variables cargadas desde .env.local"
}

# Obtener la API key de la variable de entorno
$firebaseApiKey = $env:FIREBASE_API_KEY

if (-not $firebaseApiKey) {
    Write-Host "❌ Error: FIREBASE_API_KEY no está definida"
    Write-Host "   Crea .env.local con: FIREBASE_API_KEY=tu_api_key"
    exit 1
}

# Leer template y reemplazar variables
$content = Get-Content $templatePath -Raw
$content = $content -replace '\$\{FIREBASE_API_KEY\}', $firebaseApiKey

# Escribir el archivo final
$content | Set-Content $outputPath

Write-Host "✅ google-services.json generado desde template"
Write-Host "   API Key inyectada: $($firebaseApiKey.Substring(0, 10))..."
