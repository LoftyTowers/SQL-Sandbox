# SQL Server 2022 Sandbox

Minimal local harness for SQL Server 2022 DevKit validation. This repo spins up SQL Server in Docker, applies deterministic migrations, and runs verification scripts via `sqlcmd`.

## Prerequisites

- Docker Desktop (or compatible Docker runtime)
- PowerShell 7+ recommended (Windows PowerShell works as well)

## Quickstart

From the repo root:

```powershell
.\scripts\Invoke-All.ps1
```

Expected output (trimmed):

```
Starting SQL Server container...
Waiting for SQL Server to accept connections...
SQL Server is ready.
Applying migration 000_create_database.sql (db: master)...
Applying migration 010_bootstrap.sql (db: SandboxDb)...
Migrations complete.
Running verification 000_smoke.sql...
Verification complete.
All tasks complete.
```

## Deterministic ordering

- Migrations run in lexicographic order by filename from `sql/migrations`.
- Verification scripts run in lexicographic order by filename from `sql/verify`.
- Files prefixed `000_` are executed against `master` to allow database creation.

## Default credentials

- SQL Server: `localhost,1433`
- User: `sa`
- Password: `YourStrong!Passw0rd`
- Database: `SandboxDb`

If you change the password in `docker-compose.yml`, pass the same value to the scripts:

```powershell
.\scripts\Invoke-All.ps1 -SaPassword "YourStrong!Passw0rd"
```

## Individual scripts

```powershell
.\scripts\Invoke-Migrations.ps1
.\scripts\Invoke-Verify.ps1
```
