#!/usr/bin/env bash
# ==============================================================================
# Babylon Deploy - Secret and Credential Scanner
# ==============================================================================
# Scans git working tree (staged & unstaged changes) and untracked files
# to ensure no private keys, API tokens, cloud credentials, or secrets
# are hardcoded prior to proposing changes or submitting pull requests.
#
# Exit codes:
#   0 - Clean (no secrets detected)
#   1 - Potential secrets or unmasked credentials detected
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

cd "${REPO_ROOT}"

echo "============================================================"
echo " Running Babylon Secret Scanner on git working tree..."
echo " Repository root: ${REPO_ROOT}"
echo "============================================================"

FOUND_SECRETS=0

# 1. Check for sensitive files that should never be tracked or staged
echo "Checking for sensitive file extensions in git status..."
SENSITIVE_FILES=$(git status --porcelain 2>/dev/null | awk '{print $2}' | grep -E '\.(tfvars|env|pem|key|pfx|p12)$|id_rsa' | grep -v '\.example$' || true)

if [[ -n "${SENSITIVE_FILES}" ]]; then
    echo " [ALERT] Found potential sensitive file tracked/staged:"
    echo "${SENSITIVE_FILES}" | sed 's/^/   - /'
    FOUND_SECRETS=1
fi

# 2. Check git diff (staged and unstaged added lines) for sensitive patterns
# Only examine added lines (lines starting with +) excluding git diff file header (+++)
ADDED_DIFF=$(git diff HEAD 2>/dev/null | grep -E '^\+[^+]' || true)
if [[ -z "${ADDED_DIFF}" ]]; then
    ADDED_DIFF=$(git diff 2>/dev/null | grep -E '^\+[^+]' || true)
fi

# Function to check whether match is an obvious mock / example placeholder
is_placeholder() {
    local text="$1"
    if echo "${text}" | grep -qiE "example|dummy|your-|changeme|placeholder|mock|alexadmin|<your"; then
        return 0
    else
        return 1
    fi
}

check_pattern() {
    local label="$1"
    local pattern="$2"

    if [[ -z "${ADDED_DIFF}" ]]; then
        return 0
    fi

    local matches
    matches=$(echo "${ADDED_DIFF}" | grep -E -i -e "${pattern}" || true)
    if [[ -n "${matches}" ]]; then
        local real_matches=""
        while IFS= read -r line; do
            if ! is_placeholder "${line}"; then
                real_matches+="${line}"$'\n'
            fi
        done <<< "${matches}"

        if [[ -n "${real_matches// /}" ]]; then
            echo " [ALERT] Detected ${label}:"
            echo "${real_matches}" | sed 's/^/   /'
            FOUND_SECRETS=1
        fi
    fi
}

echo "Scanning git diff (+ additions) for hardcoded secrets..."
check_pattern "AWS Access Key ID" "AKIA[0-9A-Z]{16}"
check_pattern "Private Key Header" "BEGIN [A-Z ]*PRIVATE KEY"
check_pattern "GitHub Personal Access Token" "ghp_[0-9a-zA-Z]{36}"
check_pattern "GitHub Fine-grained PAT" "github_pat_[0-9a-zA-Z_]{82}"
check_pattern "Google API Key" "AIza[0-9A-Za-z_-]{35}"
check_pattern "Slack Token" "xox[baprs]-[0-9a-zA-Z]{10,48}"
check_pattern "Generic High-Entropy Secret Assignment" "(api_key|apikey|secret_key|private_key|auth_token)[[:space:]]*=[[:space:]]*['\"][0-9a-zA-Z_-]{20,}['\"]"
check_pattern "Hardcoded MongoDB URI with credentials" "mongodb(\+srv)?:\/\/[a-zA-Z0-9_-]+:[^@[:space:]\"'<>]{4,}@"

echo "============================================================"
if [[ "${FOUND_SECRETS}" -eq 1 ]]; then
    echo " FAILED: Potential secrets detected! Please remove or mask them."
    echo "============================================================"
    exit 1
else
    echo " PASSED: No hardcoded secrets detected in git working tree."
    echo "============================================================"
    exit 0
fi
