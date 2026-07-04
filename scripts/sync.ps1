# Sync this repo's skills on native Windows (no WSL needed).
# Mirrors scripts/sync.sh: skills/ -> %USERPROFILE%\.agents\skills (all, cross-tool
# standard dir). CLAUDE.md / AGENTS.md at the repo root -> %USERPROFILE%\.claude\CLAUDE.md
# and %USERPROFILE%\.agents\AGENTS.md, backing up the old file before overwrite.
# Manifest-based prune: only entries this script installed are ever removed.
#
# Usage: powershell -ExecutionPolicy Bypass -File scripts\sync.ps1 [-DryRun] [-NoPrune]

param(
    [switch]$DryRun,
    [switch]$NoPrune
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$SkillsDir = Join-Path $RepoRoot "skills"
$ManifestName = ".agent-setup-managed"

$AllSkills = Get-ChildItem -Path $SkillsDir -Directory | Select-Object -ExpandProperty Name | Sort-Object

function Sync-Skills([string]$Dest, [string[]]$Names) {
    Write-Host "-> $Dest"
    if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $Dest | Out-Null }

    foreach ($name in $Names) {
        $src = Join-Path $SkillsDir $name
        if (-not (Test-Path $src)) { Write-Warning "missing in repo: $name"; continue }
        if ($DryRun) {
            Write-Host "  [dry-run] robocopy $name"
        } else {
            robocopy $src (Join-Path $Dest $name) /MIR /XF .DS_Store /NFL /NDL /NJH /NJS /NP | Out-Null
            if ($LASTEXITCODE -ge 8) { throw "robocopy failed for $name (exit $LASTEXITCODE)" }
        }
    }

    $manifest = Join-Path $Dest $ManifestName
    if (-not $NoPrune -and (Test-Path $manifest)) {
        foreach ($old in Get-Content $manifest | Where-Object { $_ }) {
            if ($Names -notcontains $old) {
                $stale = Join-Path $Dest $old
                if (Test-Path $stale) {
                    Write-Host "  prune: $old"
                    if (-not $DryRun) { Remove-Item -Recurse -Force $stale }
                }
            }
        }
    }

    if ($DryRun) {
        Write-Host "  [dry-run] write manifest $manifest"
    } else {
        $Names | Set-Content $manifest
    }
}

function Sync-Memory([string]$Src, [string]$Dest) {
    if (-not (Test-Path $Src)) { Write-Warning "missing in repo: $Src"; return }
    Write-Host "-> $Dest"
    $destDir = Split-Path -Parent $Dest
    if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }
    if ((Test-Path $Dest) -and
        ((Get-FileHash $Src).Hash -ne (Get-FileHash $Dest).Hash)) {
        $backup = "$Dest.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
        Write-Host "  backup: $backup"
        if (-not $DryRun) { Copy-Item $Dest $backup }
    }
    if (-not $DryRun) { Copy-Item $Src $Dest -Force }
}

$mode = if ($DryRun) { "dry-run" } else { "live" }
Write-Host "agent-setup sync ($mode, $($AllSkills.Count) skills)"

# All skills live in the cross-tool standard dir; non-Claude agents read them there.
Sync-Skills (Join-Path $env:USERPROFILE ".agents\skills") $AllSkills

# Global user memory: repo root is the source of truth (backed up before overwrite).
Sync-Memory (Join-Path $RepoRoot "CLAUDE.md") (Join-Path $env:USERPROFILE ".claude\CLAUDE.md")
Sync-Memory (Join-Path $RepoRoot "AGENTS.md") (Join-Path $env:USERPROFILE ".agents\AGENTS.md")

Write-Host "Done."
