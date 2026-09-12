$ErrorActionPreference = 'Stop'

$packagedJar = Join-Path $PSScriptRoot 'iteam-backend.jar'
if (Test-Path $packagedJar) {
    $backendRoot = $PSScriptRoot
    $jar = Get-Item $packagedJar
} else {
    $backendRoot = Split-Path -Parent $PSScriptRoot
    $jar = Get-ChildItem -Path (Join-Path $backendRoot 'target') -Filter '*.jar' -File |
        Where-Object { $_.Name -notlike '*.original' } |
        Select-Object -First 1
}

if ($null -eq $jar) {
    throw 'Runnable JAR not found. Run mvn clean package in the backend directory first.'
}

if ([string]::IsNullOrWhiteSpace($env:DB_PASSWORD)) {
    $securePassword = Read-Host 'Enter the MySQL 8.0 root password' -AsSecureString
    $pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    try {
        $env:DB_PASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer)
    }
}

if ([string]::IsNullOrWhiteSpace($env:DB_URL)) {
    $env:DB_URL = 'jdbc:mysql://127.0.0.1:3307/iteam01?createDatabaseIfNotExist=true&useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true&useSSL=false'
}

Push-Location $backendRoot
try {
    & java -jar $jar.FullName
} finally {
    $env:DB_PASSWORD = $null
    Pop-Location
}
