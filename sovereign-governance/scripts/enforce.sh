#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# SOVEREIGN GOVERNANCE — ENFORCEMENT SCRIPT
#
# Scans all repositories for AGENTS.md compliance. Reports violations.
# Optionally replaces stale copies with properly generated pointer files.
#
# Usage:
#   ./enforce.sh              Audit mode (report only, no changes)
#   ./enforce.sh --fix        Fix mode (replace stale copies with pointers)
#
# Configuration (environment variables):
#   SOVEREIGN_CANONICAL    Path to canonical AGENTS.md (required)
#   SOVEREIGN_HOME         Parent directory to scan (default: $HOME)
#   SOVEREIGN_MAX_LINES    Max lines for valid pointer (default: 50)
#
# If SOVEREIGN_CANONICAL is not set, falls back to:
#   $HOME/governance/AGENTS.md
#
# ═══════════════════════════════════════════════════════════════════════════

# ── Configuration ────────────────────────────────────────────────────────
CANONICAL="${SOVEREIGN_CANONICAL:-$HOME/governance/AGENTS.md}"
SCAN_DIR="${SOVEREIGN_HOME:-$HOME}"
MAX_LINES="${SOVEREIGN_MAX_LINES:-50}"
FIX_MODE="${1:-}"
TODAY=$(date +%Y-%m-%d)

# ── Colors ───────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# ── Banner ───────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  SOVEREIGN GOVERNANCE — ENFORCEMENT                         ║"
echo "║  One source of truth. Everything else is a pointer.         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ── Step 1: Verify canonical exists ─────────────────────────────────────
if [ ! -f "$CANONICAL" ]; then
    echo -e "${RED}CRITICAL: Canonical AGENTS.md not found at:${NC}"
    echo -e "  $CANONICAL"
    echo ""
    echo "Set SOVEREIGN_CANONICAL in your shell profile:"
    echo "  export SOVEREIGN_CANONICAL=\"/path/to/your/AGENTS.md\""
    exit 1
fi

CANONICAL_LINES=$(wc -l < "$CANONICAL" | tr -d ' ')
echo -e "${GREEN}Canonical found${NC}: $CANONICAL ($CANONICAL_LINES lines)"
echo -e "Scanning:  $SCAN_DIR (max depth 2)"
echo -e "Threshold: $MAX_LINES lines"
echo ""

# ── Helper: classify a repo ─────────────────────────────────────────────
#
# Override this function or extend the case statement to add your own repos.
# Unknown repos default to TACTICAL / ACTIVE.
#
get_repo_info() {
    local repo_name="$1"
    REPO_PURPOSE="Repository"
    REPO_LEVEL="TACTICAL"
    REPO_STATUS="ACTIVE"

    case "$repo_name" in
        # ── Add your repos here ──────────────────────────────────────
        # Example:
        #   my-api)
        #       REPO_PURPOSE="REST API service"
        #       REPO_LEVEL="SOVEREIGN"; REPO_STATUS="ACTIVE — Primary" ;;
        #   my-frontend)
        #       REPO_PURPOSE="React frontend"
        #       REPO_LEVEL="STRATEGIC"; REPO_STATUS="ACTIVE" ;;
        #   old-prototype)
        #       REPO_PURPOSE="Legacy prototype"
        #       REPO_LEVEL="NONE"; REPO_STATUS="ARCHIVED" ;;
        # ─────────────────────────────────────────────────────────────

        *) # Default: unknown repos get TACTICAL / ACTIVE
            REPO_PURPOSE="$repo_name"
            REPO_LEVEL="TACTICAL"
            REPO_STATUS="ACTIVE" ;;
    esac
}

# ── Helper: get canonical location name from path ────────────────────────
CANONICAL_DIR=$(dirname "$CANONICAL")
CANONICAL_LOCATION=$(basename "$CANONICAL_DIR")

# ── Helper: generate pointer file ───────────────────────────────────────
generate_pointer() {
    local repo_name="$1"
    get_repo_info "$repo_name"

    cat <<EOF
# AGENTS.md — POINTER FILE

**DO NOT add governance rules to this file.**  
**DO NOT duplicate protocol from the canonical source.**

## Canonical Source

All agent protocol, governance, skills, coordination, and compliance rules live in ONE place:

\`\`\`
$CANONICAL
\`\`\`

**Location:** \`$CANONICAL_LOCATION\` (The Source of Truth)  
**Authority:** Repository Owner

## This Repo

| Field | Value |
|-------|-------|
| **Repo** | \`$repo_name\` |
| **Purpose** | $REPO_PURPOSE |
| **Governance Level** | $REPO_LEVEL |
| **Status** | $REPO_STATUS |

## What To Do

1. Open \`$CANONICAL\`
2. Read it. Follow it.
3. If a rule here conflicts with the canonical — canonical wins. Always.

---

*This is a pointer file. The canonical AGENTS.md is in $CANONICAL_LOCATION.*  
*Last synced: $TODAY*
EOF
}

# ── Step 2: Scan all AGENTS.md files ────────────────────────────────────
echo -e "${BOLD}Scanning for AGENTS.md files...${NC}"
echo ""

find "$SCAN_DIR" -maxdepth 2 -name "AGENTS.md" \
    -not -path "*/node_modules/*" \
    -not -path "*/.next/*" \
    -not -path "*/.git/*" 2>/dev/null | sort | while IFS= read -r agents_file; do

    # Skip the canonical itself
    if [ "$agents_file" = "$CANONICAL" ]; then
        continue
    fi

    lines=$(wc -l < "$agents_file" | tr -d ' ')
    dir=$(dirname "$agents_file")
    repo_name=$(basename "$dir")

    # Check if it's a compliant pointer
    if [ "$lines" -lt "$MAX_LINES" ] && grep -q "POINTER FILE" "$agents_file" 2>/dev/null && grep -q "$CANONICAL_LOCATION" "$agents_file" 2>/dev/null; then
        echo -e "  ${GREEN}COMPLIANT${NC}  $repo_name ($lines lines)"
    else
        echo -e "  ${RED}STALE${NC}      $repo_name ($lines lines)"

        if [ "$FIX_MODE" = "--fix" ]; then
            generate_pointer "$repo_name" > "$agents_file"
            echo -e "    ${YELLOW}-> Replaced with pointer${NC}"
        fi
    fi
done

echo ""

# ── Step 3: Count and report ────────────────────────────────────────────
TOTAL_C=$(find "$SCAN_DIR" -maxdepth 2 -name "AGENTS.md" \
    -not -path "*/node_modules/*" \
    -not -path "*/.next/*" \
    -not -path "*/.git/*" 2>/dev/null | grep -v "$CANONICAL" | wc -l | tr -d ' ')

STALE_C=$(find "$SCAN_DIR" -maxdepth 2 -name "AGENTS.md" \
    -not -path "*/node_modules/*" \
    -not -path "*/.next/*" \
    -not -path "*/.git/*" 2>/dev/null | grep -v "$CANONICAL" | while IFS= read -r f; do
    lines=$(wc -l < "$f" | tr -d ' ')
    if [ "$lines" -ge "$MAX_LINES" ] || ! grep -q "POINTER FILE" "$f" 2>/dev/null || ! grep -q "$CANONICAL_LOCATION" "$f" 2>/dev/null; then
        echo "STALE"
    fi
done | wc -l | tr -d ' ')

COMPLIANT_C=$((TOTAL_C - STALE_C))

echo "═══════════════════════════════════════════════════════════════"
echo ""
echo -e "${BOLD}GOVERNANCE REPORT${NC}"
echo ""
echo -e "  Canonical:   $CANONICAL ($CANONICAL_LINES lines)"
echo -e "  Repos found: $TOTAL_C"
echo -e "  ${GREEN}Compliant:   $COMPLIANT_C${NC}"
echo -e "  ${RED}Stale:       $STALE_C${NC}"
echo ""

if [ "$STALE_C" -eq 0 ]; then
    echo -e "${GREEN}${BOLD}STATUS: 100% COMPLIANT${NC}"
    echo -e "${GREEN}All repos point to the canonical AGENTS.md${NC}"
else
    if [ "$FIX_MODE" = "--fix" ]; then
        echo -e "${GREEN}${BOLD}ALL STALE COPIES REPLACED WITH POINTERS${NC}"
        echo "Run again without --fix to verify."
    else
        echo -e "${RED}${BOLD}$STALE_C GOVERNANCE VIOLATIONS${NC}"
        echo ""
        echo "Run with --fix to replace stale copies with pointers:"
        echo ""
        echo -e "  ${YELLOW}$0 --fix${NC}"
    fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""
