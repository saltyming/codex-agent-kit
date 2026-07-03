#!/bin/sh
set -e

REPO="${REPO:-saltyming/codex-agent-kit}"
BRANCH="${BRANCH:-main}"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"

AGENTS_FILE="$CODEX_HOME/AGENTS.md"
RULES_DIR="$CODEX_HOME/rules"
SKILLS_DIR="$CODEX_HOME/skills"
MANIFEST="$CODEX_HOME/.codex-agent-kit-manifest"

RULE_FILES="
codex-agent-kit--task-execution.md
codex-agent-kit--palette.md
codex-agent-kit--delegation.md
codex-agent-kit--git-workflow.md
codex-agent-kit--framework-conventions.md
codex-agent-kit--aside.md
codex-agent-kit--dispatch.md
"

SKILL_NAMES="
palette-init
palette-rules
palette-spec
palette-ui
palette-ux
"

fetch() {
    url="$1"
    dest="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$dest"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$dest" "$url"
    else
        echo "Error: curl or wget required" >&2
        exit 1
    fi
}

uninstall() {
    if [ ! -f "$MANIFEST" ]; then
        echo "No manifest at $MANIFEST. Nothing to uninstall."
        exit 0
    fi
    while IFS= read -r f; do
        case "$f" in "## "*) continue ;; esac
        if [ -d "$f" ]; then
            rm -rf "$f"
            echo "  removed $f"
        elif [ -f "$f" ]; then
            rm -f "$f"
            echo "  removed $f"
        fi
    done < "$MANIFEST"
    rm -f "$MANIFEST"
    echo "Uninstalled."
    exit 0
}

for arg in "$@"; do
    case "$arg" in
        --uninstall) uninstall ;;
        -h|--help)
            echo "Usage: $0 [--uninstall]"
            echo "Env: CODEX_HOME, REPO, BRANCH"
            exit 0
            ;;
    esac
done

echo "Installing codex-agent-kit..."
echo "  CODEX_HOME: $CODEX_HOME"

mkdir -p "$CODEX_HOME" "$RULES_DIR" "$SKILLS_DIR"
echo "## install @ $(date -u +%FT%TZ 2>/dev/null || date)" > "$MANIFEST"

fetch "$RAW_BASE/AGENTS.md" "$AGENTS_FILE"
echo "$AGENTS_FILE" >> "$MANIFEST"
echo "  wrote $AGENTS_FILE"

for f in $RULE_FILES; do
    dest="$RULES_DIR/$f"
    fetch "$RAW_BASE/codex-rules/$f" "$dest"
    echo "$dest" >> "$MANIFEST"
    echo "  rule: $dest"
done

for s in $SKILL_NAMES; do
    dest="$SKILLS_DIR/$s"
    rm -rf "$dest"
    mkdir -p "$dest"
    fetch "$RAW_BASE/codex-skills/$s/SKILL.md" "$dest/SKILL.md"
    echo "$dest" >> "$MANIFEST"
    echo "  skill: $dest"
done

echo ""
echo "Installed codex-agent-kit."
echo "Manifest: $MANIFEST"
