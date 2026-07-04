param(
    [switch]$Uninstall,
    [switch]$SkipMcp,
    [string]$CodexHome = "$env:USERPROFILE\.codex",
    [string]$Repo = "saltyming/codex-agent-kit",
    [string]$Branch = "main",
    [string]$SlateRepo = "saltyming/slate-agent-kit",
    [string]$DispatchRoots = $env:DISPATCH_ROOTS
)

$ErrorActionPreference = "Stop"

$RawBase = "https://raw.githubusercontent.com/$Repo/$Branch"
$AgentsFile = Join-Path $CodexHome "AGENTS.md"
$RulesDir = Join-Path $CodexHome "rules"
$SkillsDir = Join-Path $CodexHome "skills"
$Manifest = Join-Path $CodexHome ".codex-agent-kit-manifest"

# Concat order matters: the manual first, then the surface binding, then policy.
$RuleFiles = @(
    "codex-agent-kit--codex-surface.md",
    "codex-agent-kit--task-execution.md",
    "codex-agent-kit--palette.md",
    "codex-agent-kit--delegation.md",
    "codex-agent-kit--git-workflow.md",
    "codex-agent-kit--framework-conventions.md",
    "codex-agent-kit--aside.md",
    "codex-agent-kit--dispatch.md"
)

$SkillNames = @("palette-init", "palette-rules", "palette-spec", "palette-ui", "palette-ux")

function Fetch([string]$Url, [string]$Dest) {
    Invoke-WebRequest -Uri $Url -OutFile $Dest
}

if ($Uninstall) {
    if (-not (Test-Path $Manifest)) {
        Write-Host "No manifest at $Manifest. Nothing to uninstall."
        return
    }
    # Signature-guarded: keep user-owned (-custom: signed) and unrecognized files.
    Get-Content $Manifest | ForEach-Object {
        if ($_ -match "^## ") { return }
        if (Test-Path $_ -PathType Container) {
            $skill = Join-Path $_ "SKILL.md"
            $head = if (Test-Path $skill) { (Get-Content $skill -TotalCount 8) -join "`n" } else { "" }
            if ($head -match "slate-agent-kit:common|codex-agent-kit") {
                Remove-Item $_ -Recurse -Force
                Write-Host "  removed $_"
            } else {
                Write-Host "  kept (unrecognized signature): $_"
            }
        } elseif (Test-Path $_ -PathType Leaf) {
            $head = Get-Content $_ -TotalCount 1
            if ($head -match "-custom:") {
                Write-Host "  kept (user-owned): $_"
            } elseif ($head -match "slate-agent-kit:common|codex-agent-kit") {
                Remove-Item $_ -Force
                Write-Host "  removed $_"
            } else {
                Write-Host "  kept (unrecognized signature): $_"
            }
        }
    }
    Remove-Item $Manifest -Force
    Write-Host "Uninstalled."
    return
}

Write-Host "Installing codex-agent-kit..."
Write-Host "  CODEX_HOME: $CodexHome"
Write-Host "  AGENTS.md:  $AgentsFile (manual + rules concatenated)"

New-Item -ItemType Directory -Force -Path $CodexHome, $RulesDir, $SkillsDir | Out-Null
"## install @ $((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))" | Set-Content -Path $Manifest

# Back up a pre-existing AGENTS.md that this kit does not manage.
if (Test-Path $AgentsFile) {
    $head = Get-Content $AgentsFile -TotalCount 1
    if ($head -notmatch "slate-agent-kit:common") {
        $bak = "$AgentsFile.bak-$((Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ'))"
        Copy-Item $AgentsFile $bak
        Write-Host "WARNING: existing $AgentsFile is not managed by this kit; backed up to $bak"
        Add-Content -Path $Manifest -Value "## backup: $bak"
    }
}

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("codex-agent-kit-" + [System.Guid]::NewGuid())
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
try {
    Fetch "$RawBase/AGENTS.md" (Join-Path $tmp "AGENTS.md")
    $parts = @((Get-Content (Join-Path $tmp "AGENTS.md") -Raw))
    foreach ($f in $RuleFiles) {
        $src = Join-Path $tmp $f
        Fetch "$RawBase/codex-rules/$f" $src
        $parts += (Get-Content $src -Raw)
        $dest = Join-Path $RulesDir $f
        Copy-Item $src $dest -Force
        Add-Content -Path $Manifest -Value $dest
        Write-Host "  rule: $dest"
    }
    ($parts -join "`n---`n`n") | Set-Content -Path $AgentsFile -NoNewline
    Add-Content -Path $AgentsFile -Value ""
    Add-Content -Path $Manifest -Value $AgentsFile
    Write-Host "  wrote $AgentsFile"

    foreach ($s in $SkillNames) {
        $dest = Join-Path $SkillsDir $s
        if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
        New-Item -ItemType Directory -Force -Path $dest | Out-Null
        Fetch "$RawBase/codex-skills/$s/SKILL.md" (Join-Path $dest "SKILL.md")
        Add-Content -Path $Manifest -Value $dest
        Write-Host "  skill: $dest"
    }
} finally {
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

# ── Shared MCP servers (aside, dispatch) ──────────────────────────────
# Registered natively on Windows: slate's install-mcp.sh is POSIX-only and
# cannot run here. Binaries come from slate-agent-kit's release .zip; codex mcp
# add writes them into $CODEX_HOME/config.toml exactly as the POSIX path does.
if (-not $SkipMcp -and (Get-Command codex -ErrorAction SilentlyContinue)) {
    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "aarch64" } else { "x86_64" }
    $platform = "$arch-pc-windows-msvc"
    $binDir = Join-Path $CodexHome "slate-agent-kit\bin"
    New-Item -ItemType Directory -Force -Path $binDir | Out-Null
    $mcpOk = $true
    foreach ($srv in @("aside", "dispatch")) {
        try {
            $url = "https://github.com/$SlateRepo/releases/latest/download/$srv-$platform.zip"
            $zip = Join-Path ([System.IO.Path]::GetTempPath()) ("$srv-$platform-" + [System.Guid]::NewGuid() + ".zip")
            Invoke-WebRequest -Uri $url -OutFile $zip
            $ex = Join-Path ([System.IO.Path]::GetTempPath()) ("slate-$srv-" + [System.Guid]::NewGuid())
            Expand-Archive -Path $zip -DestinationPath $ex -Force
            Copy-Item (Join-Path $ex "$srv.exe") (Join-Path $binDir "$srv.exe") -Force
            Remove-Item $zip -Force -ErrorAction SilentlyContinue
            Remove-Item $ex -Recurse -Force -ErrorAction SilentlyContinue
        } catch {
            Write-Host "  Could not fetch $srv from $SlateRepo releases: $_"
            $mcpOk = $false
        }
    }
    if ($mcpOk) {
        $asideExe = Join-Path $binDir "aside.exe"
        $dispatchExe = Join-Path $binDir "dispatch.exe"
        $stateHome = Join-Path $CodexHome "slate-agent-kit"
        codex mcp remove aside 2>$null | Out-Null
        codex mcp remove dispatch 2>$null | Out-Null
        codex mcp add aside --env ASIDE_HARNESS=codex -- $asideExe
        $dispatchAdd = @("mcp", "add", "dispatch", "--env", "SLATE_AGENT_STATE_HOME=$stateHome")
        if ($DispatchRoots) { $dispatchAdd += @("--env", "DISPATCH_EXTRA_ROOTS=$DispatchRoots") }
        $dispatchAdd += @("--", $dispatchExe)
        & codex @dispatchAdd
        Write-Host "  Registered aside + dispatch MCP servers in $CodexHome\config.toml"
        if (-not $DispatchRoots) {
            Write-Host "  Note: no -DispatchRoots given; dispatch will reject working_dirs outside CODEX_HOME (no_project_root) until set."
        }
    }
} elseif (-not $SkipMcp) {
    Write-Host "NOTE: codex CLI not found — skipped MCP registration. Install codex and re-run,"
    Write-Host "or use slate-agent-kit's tooling/install-mcp.sh --configure-codex under WSL/POSIX."
}

Write-Host ""
Write-Host "Installed codex-agent-kit."
Write-Host "Manifest: $Manifest"
Write-Host ""
# ── aside/dispatch preferences (the shared configure-prefs.ps1) ──
$prefsTmp = Join-Path $env:TEMP ("codex-prefs-" + [System.Guid]::NewGuid())
New-Item -ItemType Directory -Force -Path $prefsTmp | Out-Null
Invoke-WebRequest -Uri "$RawBase/scripts/configure-prefs.ps1" -OutFile (Join-Path $prefsTmp "configure-prefs.ps1")
foreach ($t in @("aside", "dispatch")) {
    Invoke-WebRequest -Uri "$RawBase/scripts/codex-agent-kit--$t-prefs.md.tmpl" -OutFile (Join-Path $prefsTmp "codex-agent-kit--$t-prefs.md.tmpl")
}
& (Join-Path $prefsTmp "configure-prefs.ps1") -RulesDir $RulesDir -Prefix "codex-agent-kit" -Manifest $Manifest
Remove-Item $prefsTmp -Recurse -Force -ErrorAction SilentlyContinue
