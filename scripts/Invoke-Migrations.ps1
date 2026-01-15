[CmdletBinding()]
param(
    [string]$SaPassword = "YourStrong!Passw0rd",
    [string]$Database = "SandboxDb",
    [string]$Service = "sqlserver",
    [int]$MaxAttempts = 30
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
    param(
        [string]$SqlFile,
        [string]$DatabaseOverride
    )
    $db = if ($DatabaseOverride) { $DatabaseOverride } else { $Database }
    $containerPath = Convert-ToContainerPath $SqlFile
    $command = "/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P '$SaPassword' -d '$db' -C -b -i '$containerPath'"
    docker compose exec -T $Service /bin/bash -lc $command
    if ($LASTEXITCODE -ne 0) {
        throw "sqlcmd failed for $SqlFile"
    }
}

function Wait-ForSqlServer {
    Write-Host "Waiting for SQL Server to accept connections..."
    $probe = "/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P '$SaPassword' -Q 'SELECT 1' -C -l 5 -b"
    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        docker compose exec -T $Service /bin/bash -lc $probe | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "SQL Server is ready."
            return
        }
        Start-Sleep -Seconds 2
    }
    throw "SQL Server did not become ready after $MaxAttempts attempts."
}

Push-Location $RepoRoot
try {
    Wait-ForSqlServer

    $migrationsPath = Join-Path $RepoRoot "sql/migrations"
    if (-not (Test-Path $migrationsPath)) {
        Write-Host "No migrations directory found at $migrationsPath."
        return
    }

    $migrations = Get-ChildItem -Path $migrationsPath -Filter "*.sql" | Sort-Object Name
    if ($migrations.Count -eq 0) {
        Write-Host "No migrations found."
        return
    }

    foreach ($migration in $migrations) {
        $targetDb = if ($migration.Name -like "000_*") { "master" } else { $Database }
        Write-Host "Applying migration $($migration.Name) (db: $targetDb)..."
        Invoke-ComposeSqlcmd -SqlFile $migration.FullName -DatabaseOverride $targetDb
    }
    Write-Host "Migrations complete."
}
finally {
    Pop-Location
}
