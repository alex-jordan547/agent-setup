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

function Sync-ClaudeSkills([string]$Dest, [string]$AgentSkills, [string[]]$Names) {
    Write-Host "-> $Dest"
    if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $Dest | Out-Null }

    $managed = @()
    foreach ($name in $Names) {
        $link = Join-Path $Dest $name
        $target = Join-Path $AgentSkills $name
        $existing = Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue
        if ($null -eq $existing) {
            if ($DryRun) {
                Write-Host "  [dry-run] link $link -> $target"
            } else {
                New-Item -ItemType SymbolicLink -Path $link -Target $target | Out-Null
            }
            $managed += $name
        } elseif ($existing.LinkType -eq "SymbolicLink" -and $existing.Target -eq $target) {
            $managed += $name
        } else {
            Write-Warning "preserving existing entry: $link"
        }
    }

    $manifest = Join-Path $Dest $ManifestName
    if (-not $NoPrune -and (Test-Path $manifest)) {
        foreach ($old in Get-Content $manifest | Where-Object { $_ }) {
            if ($managed -notcontains $old) {
                $stale = Join-Path $Dest $old
                $existing = Get-Item -LiteralPath $stale -Force -ErrorAction SilentlyContinue
                if ($null -ne $existing -and $existing.LinkType -eq "SymbolicLink") {
                    Write-Host "  prune: $old"
                    if (-not $DryRun) { Remove-Item -Force -LiteralPath $stale }
                }
            }
        }
    }

    if ($DryRun) {
        Write-Host "  [dry-run] write manifest $manifest"
    } else {
        $managed | Set-Content $manifest
    }
}

function Sync-Agents([string]$Dest) {
    $srcDir = Join-Path $RepoRoot "agents"
    if (-not (Test-Path $srcDir)) { return }
    Write-Host "-> $Dest"
    if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $Dest | Out-Null }

    $names = Get-ChildItem -Path $srcDir -Filter *.toml | Select-Object -ExpandProperty Name
    foreach ($name in $names) {
        if (-not $DryRun) { Copy-Item (Join-Path $srcDir $name) (Join-Path $Dest $name) -Force }
    }

    $manifest = Join-Path $Dest $ManifestName
    if (-not $NoPrune -and (Test-Path $manifest)) {
        foreach ($old in Get-Content $manifest | Where-Object { $_ }) {
            if ($names -notcontains $old) {
                $stale = Join-Path $Dest $old
                if (Test-Path $stale) {
                    Write-Host "  prune: $old"
                    if (-not $DryRun) { Remove-Item -Force $stale }
                }
            }
        }
    }

    if ($DryRun) {
        Write-Host "  [dry-run] write manifest $manifest"
    } else {
        $names | Set-Content $manifest
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
Sync-ClaudeSkills (Join-Path $env:USERPROFILE ".claude\skills") (Join-Path $env:USERPROFILE ".agents\skills") $AllSkills

# Codex custom subagents: agents/*.toml -> %USERPROFILE%\.codex\agents (personal scope).
Sync-Agents (Join-Path $env:USERPROFILE ".codex\agents")

# Global user memory: repo root is the source of truth (backed up before overwrite).
Sync-Memory (Join-Path $RepoRoot "CLAUDE.md") (Join-Path $env:USERPROFILE ".claude\CLAUDE.md")
Sync-Memory (Join-Path $RepoRoot "AGENTS.md") (Join-Path $env:USERPROFILE ".agents\AGENTS.md")

Write-Host "Done."
