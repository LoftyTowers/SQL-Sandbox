[CmdletBinding()]
param(
    [string]$SaPassword = "YourStrong!Passw0rd",
    [string]$Database = "SandboxDb",
    [string]$Service = "sqlserver"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

Push-Location $RepoRoot
try {
    Write-Host "Starting SQL Server container..."
    docker compose up -d
    if ($LASTEXITCODE -ne 0) {
        throw "docker compose up failed."
    }

    & (Join-Path $PSScriptRoot "Invoke-Migrations.ps1") -SaPassword $SaPassword -Database $Database -Service $Service
    & (Join-Path $PSScriptRoot "Invoke-Verify.ps1") -SaPassword $SaPassword -Database $Database -Service $Service

    Write-Host "All tasks complete."
}
finally {
    Pop-Location
}
