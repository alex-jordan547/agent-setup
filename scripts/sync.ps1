# Sync this repo's skills on native Windows (no WSL needed).
# Mirrors scripts/sync.sh: skills/ -> %USERPROFILE%\.agents\skills (all)
# and %USERPROFILE%\.codex\skills (CODEX_SKILLS from config.env).
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

# Parse CODEX_SKILLS="a b c" from config.env
$configLine = Select-String -Path (Join-Path $RepoRoot "config.env") -Pattern '^CODEX_SKILLS="(.*)"'
$CodexSkills = $configLine.Matches[0].Groups[1].Value -split '\s+' | Where-Object { $_ }

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

$mode = if ($DryRun) { "dry-run" } else { "live" }
Write-Host "agent-setup sync ($mode, $($AllSkills.Count) skills)"

Sync-Skills (Join-Path $env:USERPROFILE ".agents\skills") $AllSkills
Sync-Skills (Join-Path $env:USERPROFILE ".codex\skills") $CodexSkills

Write-Host "Done."
