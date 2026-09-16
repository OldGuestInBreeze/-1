$ErrorActionPreference = 'Stop'

$backendRoot = Split-Path -Parent $PSScriptRoot
$distributionRoot = Join-Path $backendRoot 'target\distribution'
$zipPath = Join-Path $backendRoot 'target\iteam-backend-windows.zip'
$settingsPath = Join-Path $backendRoot 'maven-settings.xml'

Push-Location $backendRoot
try {
    $mavenArguments = @('clean', 'package')
    if (Test-Path $settingsPath) {
        $mavenArguments = @('-s', $settingsPath) + $mavenArguments
    }
    & mvn @mavenArguments
    if ($LASTEXITCODE -ne 0) {
        throw 'Maven build failed.'
    }

    Remove-Item $distributionRoot -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $distributionRoot | Out-Null
    $jar = Get-ChildItem -Path (Join-Path $backendRoot 'target') -Filter '*.jar' -File |
        Where-Object { $_.Name -notlike '*.original' } |
        Select-Object -First 1
    Copy-Item $jar.FullName (Join-Path $distributionRoot 'iteam-backend.jar')
    Copy-Item (Join-Path $backendRoot 'README.md') $distributionRoot
    Copy-Item $settingsPath $distributionRoot
    Copy-Item (Join-Path $backendRoot 'scripts\start-backend.bat') $distributionRoot
    Copy-Item (Join-Path $backendRoot 'scripts\start-backend.ps1') $distributionRoot
    Copy-Item (Join-Path $backendRoot 'src\main\resources\schema.sql') $distributionRoot

    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
    Compress-Archive -Path (Join-Path $distributionRoot '*') -DestinationPath $zipPath
    Write-Host "Package created: $zipPath"
} finally {
    Pop-Location
}
