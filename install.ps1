param(
    [switch]$Uninstall,
    [string]$CodexHome = "$env:USERPROFILE\.codex",
    [string]$Repo = "saltyming/codex-agent-kit",
    [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"

$RawBase = "https://raw.githubusercontent.com/$Repo/$Branch"
$AgentsFile = Join-Path $CodexHome "AGENTS.md"
$RulesDir = Join-Path $CodexHome "rules"
$SkillsDir = Join-Path $CodexHome "skills"
$Manifest = Join-Path $CodexHome ".codex-agent-kit-manifest"

$RuleFiles = @(
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
    Get-Content $Manifest | ForEach-Object {
        if ($_ -match "^## ") { return }
        if (Test-Path $_ -PathType Container) {
            Remove-Item $_ -Recurse -Force
            Write-Host "  removed $_"
        } elseif (Test-Path $_ -PathType Leaf) {
            Remove-Item $_ -Force
            Write-Host "  removed $_"
        }
    }
    Remove-Item $Manifest -Force
    Write-Host "Uninstalled."
    return
}

Write-Host "Installing codex-agent-kit..."
Write-Host "  CODEX_HOME: $CodexHome"

New-Item -ItemType Directory -Force -Path $CodexHome, $RulesDir, $SkillsDir | Out-Null
"## install @ $((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))" | Set-Content -Path $Manifest

Fetch "$RawBase/AGENTS.md" $AgentsFile
Add-Content -Path $Manifest -Value $AgentsFile
Write-Host "  wrote $AgentsFile"

foreach ($f in $RuleFiles) {
    $dest = Join-Path $RulesDir $f
    Fetch "$RawBase/codex-rules/$f" $dest
    Add-Content -Path $Manifest -Value $dest
    Write-Host "  rule: $dest"
}

foreach ($s in $SkillNames) {
    $dest = Join-Path $SkillsDir $s
    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Fetch "$RawBase/codex-skills/$s/SKILL.md" (Join-Path $dest "SKILL.md")
    Add-Content -Path $Manifest -Value $dest
    Write-Host "  skill: $dest"
}

Write-Host ""
Write-Host "Installed codex-agent-kit."
Write-Host "Manifest: $Manifest"
