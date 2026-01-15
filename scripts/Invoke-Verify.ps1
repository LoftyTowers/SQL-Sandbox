[CmdletBinding()]
param(
    [string]$SaPassword = "YourStrong!Passw0rd",
    [string]$Database = "SandboxDb",
    [string]$Service = "sqlserver"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

function Convert-ToContainerPath {
    param([string]$FullPath)
    $relative = [System.IO.Path]::GetRelativePath($RepoRoot, $FullPath)
    "/workspace/" + ($relative -replace "\\", "/")
}

function Invoke-ComposeSqlcmd {
    param([string]$SqlFile)
    $containerPath = Convert-ToContainerPath $SqlFile
    $command = "/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P '$SaPassword' -d '$Database' -C -b -i '$containerPath'"
    docker compose exec -T $Service /bin/bash -lc $command
    if ($LASTEXITCODE -ne 0) {
        throw "Verification failed for $SqlFile"
    }
}

Push-Location $RepoRoot
try {
    $verifyPath = Join-Path $RepoRoot "sql/verify"
    if (-not (Test-Path $verifyPath)) {
        Write-Host "No verify directory found at $verifyPath."
        return
    }

    $checks = Get-ChildItem -Path $verifyPath -Filter "*.sql" | Sort-Object Name
    if ($checks.Count -eq 0) {
        Write-Host "No verification scripts found."
        return
    }

    foreach ($check in $checks) {
        Write-Host "Running verification $($check.Name)..."
        Invoke-ComposeSqlcmd -SqlFile $check.FullName
    }
    Write-Host "Verification complete."
}
finally {
    Pop-Location
}
