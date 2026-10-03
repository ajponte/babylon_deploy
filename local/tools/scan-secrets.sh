#!/usr/bin/env bash
# ==============================================================================
# Babylon Deploy - Secret and Credential Scanner
# ==============================================================================
# Scans git working tree (staged & unstaged changes) AND untracked files
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
# Using cut -c 4- to handle filenames with spaces properly
echo "Checking for sensitive file extensions in git status..."
SENSITIVE_FILES=$(git status --porcelain 2>/dev/null | cut -c 4- | tr -d '"' | grep -E '\.(tfvars|env|pem|key|pfx|p12)$|id_rsa' | grep -v '\.example$' || true)

if [[ -n "${SENSITIVE_FILES}" ]]; then
    echo " [ALERT] Found potential sensitive file tracked/staged:"
    echo "${SENSITIVE_FILES}" | sed 's/^/   - /'
    FOUND_SECRETS=1
fi

# 2. Collect diff additions and untracked file contents into temp file for scanning
TMP_SCAN_FILE=$(mktemp /tmp/babylon_scan.XXXXXX)
trap 'rm -f "${TMP_SCAN_FILE}"' EXIT

# Collect staged + unstaged git diff additions
(git diff HEAD 2>/dev/null | grep -E '^\+[^+]' || git diff 2>/dev/null | grep -E '^\+[^+]' || true) > "${TMP_SCAN_FILE}"

# Collect untracked non-binary files (respecting .gitignore)
while IFS= read -r ufile; do
    if [[ -f "${ufile}" ]]; then
        # Confirm file is non-empty text
        if grep -qI . "${ufile}" 2>/dev/null; then
            sed "s|^|${ufile}: |" "${ufile}" >> "${TMP_SCAN_FILE}"
        fi
    fi
done < <(git ls-files --others --exclude-standard 2>/dev/null || true)

# Function to check whether value contains obvious placeholder markers
is_placeholder() {
    local text="$1"
    if echo "${text}" | grep -qiE "(your-[a-zA-Z0-9_-]+|<your|dummy|changeme|placeholder|example_key|my-secret-key)"; then
        return 0
    else
        return 1
    fi
}

check_pattern() {
    local label="$1"
    local pattern="$2"

    if [[ ! -s "${TMP_SCAN_FILE}" ]]; then
        return 0
    fi

    local matches
    matches=$(grep -E -i -e "${pattern}" "${TMP_SCAN_FILE}" || true)
    if [[ -n "${matches}" ]]; then
        local real_matches=""
        while IFS= read -r line; do
            if [[ -n "${line}" ]] && ! is_placeholder "${line}"; then
                real_matches+="${line}"$'\n'
            fi
        done <<< "${matches}"

        if [[ -n "${real_matches// /}" ]]; then
            echo " [ALERT] Detected ${label}:"
            echo "${real_matches}" | head -n 10 | sed 's/^/   /'
            FOUND_SECRETS=1
        fi
    fi
}

echo "Scanning git diff (+ additions) and untracked files for secrets..."
# AWS Permanent and Temporary Access Keys
check_pattern "AWS Access Key ID" "(AKIA|ASIA)[0-9A-Z]{16}"
# Private Key Headers
check_pattern "Private Key Header" "BEGIN [A-Z ]*PRIVATE KEY"
# GitHub Tokens
check_pattern "GitHub Personal Access Token" "ghp_[0-9a-zA-Z]{36}"
check_pattern "GitHub Fine-grained PAT" "github_pat_[0-9a-zA-Z_]{82}"
# Google & Slack
check_pattern "Google API Key" "AIza[0-9A-Za-z_-]{35}"
check_pattern "Slack Token" "xox[baprs]-[0-9a-zA-Z]{10,48}"
# JSON, YAML, or Shell key assignments (handles both = and : assignments)
check_pattern "High-Entropy Secret Assignment" "['\"]?(api_key|apikey|secret_key|secret_access_key|aws_secret_access_key|private_key|auth_token|pat_token)['\"]?[[:space:]]*[:=][[:space:]]*['\"][0-9a-zA-Z_+=/ -]{16,}['\"]"
# Hardcoded MongoDB URI with raw password
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
