#!/usr/bin/env bash
# validate.sh — Devil's Advocate quality sweep
# Checks all quality standards before a PR is merged.
# Usage: bash scripts/validate.sh
# Compatible: macOS, Linux, Git Bash (Windows), WSL

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISSUES=()
PASS=0
FAIL=0

ok()   { echo "  ✅ $1"; ((++PASS)); }
fail() { echo "  ❌ $1"; ISSUES+=("$1"); ((++FAIL)); }
head() { echo; echo "── $1 ──────────────────────────────────────"; }

# ─── Check 1: Version consistency ────────────────────────────────────────────
head "Version"
VERSION=$(grep -m1 '^version:' "$ROOT/SKILL.md" | awk '{print $2}')
CHANGELOG_VER=$(grep -m1 '^## \[[0-9]' "$ROOT/CHANGELOG.md" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)
if [ "$VERSION" = "$CHANGELOG_VER" ]; then
  ok "SKILL.md version ($VERSION) matches latest CHANGELOG entry"
else
  fail "Version mismatch: SKILL.md=$VERSION, CHANGELOG latest=$CHANGELOG_VER"
fi

# ─── Check 2: Fence balance (even number of ``` per file) ────────────────────
head "Fence balance"
FENCE_ISSUES=0
while IFS= read -r -d '' file; do
  count=$(grep -c '^```' "$file" 2>/dev/null || true)
  if (( count % 2 != 0 )); then
    fail "Odd fence count ($count) in: ${file#$ROOT/}"
    ((++FENCE_ISSUES))
  fi
done < <(find "$ROOT" -name "*.md" -not -path "*/.git/*" -print0)
(( FENCE_ISSUES == 0 )) && ok "All .md files have balanced fences"

# ─── Check 3: Gate blocks in all examples ────────────────────────────────────
head "Gate blocks (examples)"
EXAMPLE_ISSUES=0
for file in "$ROOT/examples/"*.md; do
  name=$(basename "$file")
  content=$(cat "$file")
  missing=()
  echo "$content" | grep -q "✅ Proceed"  || missing+=("✅ Proceed")
  echo "$content" | grep -q "🔁 Revise"   || missing+=("🔁 Revise")
  echo "$content" | grep -q "❌ Cancel"   || missing+=("❌ Cancel")
  echo "$content" | grep -q '`continue`'  || missing+=("\`continue\`")
  if (( ${#missing[@]} > 0 )); then
    fail "Gate incomplete in $name — missing: ${missing[*]}"
    ((++EXAMPLE_ISSUES))
  fi
done
(( EXAMPLE_ISSUES == 0 )) && ok "All examples have complete Gate blocks"

# ─── Check 4: `continue` wording ─────────────────────────────────────────────
head "Continue wording"
CONTINUE_ISSUES=0
for file in "$ROOT/examples/"*.md; do
  name=$(basename "$file")
  # Verify the FULL correct phrase exists (positive check)
  if ! grep -q "risks remain active and unmitigated" "$file"; then
    fail "Incorrect or missing 'continue' wording in $name — expected: 'proceed without addressing remaining issues (risks remain active and unmitigated)'"
    ((++CONTINUE_ISSUES))
  fi
done
(( CONTINUE_ISSUES == 0 )) && ok "'continue' wording correct in all examples"
# Check canonical sources too
for canonical in "$ROOT/SKILL.md" "$ROOT/frameworks/output-format.md"; do
  cname=$(basename "$canonical")
  if ! grep -q "risks remain active and unmitigated" "$canonical"; then
    fail "Canonical 'continue' wording missing or incorrect in $cname"
    ((++CONTINUE_ISSUES))
  fi
done

# ─── Check 5: All examples referenced in SKILL.md index ─────────────────────
head "SKILL.md index completeness"
INDEX_ISSUES=0
for file in "$ROOT/examples/"*.md; do
  name=$(basename "$file")
  if ! grep -q "$name" "$ROOT/SKILL.md"; then
    fail "Not in SKILL.md index: $name"
    ((++INDEX_ISSUES))
  fi
done
(( INDEX_ISSUES == 0 )) && ok "All examples are indexed in SKILL.md"

# ─── Check 6: No stale legacy text ───────────────────────────────────────────
head "Stale text"
STALE_EXCLUDE="CONTRIBUTING.md PULL_REQUEST_TEMPLATE.md CHANGELOG.md validate.sh"
STALE_ISSUES=0
while IFS= read -r -d '' file; do
  name=$(basename "$file")
  skip=false
  for ex in $STALE_EXCLUDE; do [[ "$name" == "$ex" ]] && skip=true; done
  if ! $skip; then
    if grep -qE "with implementation|14-dimension" "$file"; then
      fail "Stale text in: ${file#$ROOT/}"
      ((++STALE_ISSUES))
    fi
  fi
done < <(find "$ROOT" -name "*.md" -not -path "*/.git/*" -print0)
(( STALE_ISSUES == 0 )) && ok "No stale text found"

# ─── Check 7: Required GitHub project files ──────────────────────────────────
head "GitHub project files"
for f in README.md LICENSE CONTRIBUTING.md CODE_OF_CONDUCT.md CHANGELOG.md SECURITY.md .gitignore \
          .gitattributes scripts/validate.sh \
          .github/ISSUE_TEMPLATE/bug_report.yml .github/ISSUE_TEMPLATE/feature_request.yml \
          .github/PULL_REQUEST_TEMPLATE.md .github/workflows/validate.yml; do
  if [ -f "$ROOT/$f" ]; then
    ok "$f present"
  else
    fail "Missing: $f"
  fi
done


# ─── Check 8: Example version stamps match SKILL.md ─────────────────────────
head "Example version stamps"
SKILL_VER=$(grep -m1 '^version:' "$ROOT/SKILL.md" | sed 's/version: *//')
VERSION_ISSUES=0
while IFS= read -r -d '' file; do
  if grep -q "Skill version" "$file"; then
    ex_ver=$(grep -m1 "Skill version" "$file" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [ "$ex_ver" != "$SKILL_VER" ]; then
      fail "Version mismatch in ${file#$ROOT/}: example=$ex_ver, skill=$SKILL_VER"
      ((++VERSION_ISSUES))
    fi
  else
    fail "Missing 'Skill version' stamp in ${file#$ROOT/}"
    ((++VERSION_ISSUES))
  fi
done < <(find "$ROOT/examples" -name "*.md" -print0)
(( VERSION_ISSUES == 0 )) && ok "All example version stamps match v$SKILL_VER"

# ─── Check 9: Framework files referenced in SKILL.md Index exist on disk ─────
head "Framework files on disk"
MISSING_ISSUES=0
while IFS= read -r f; do
  if [ -f "$ROOT/$f" ]; then
    ok "$f"
  else
    fail "Referenced in SKILL.md but missing: $f"
    ((++MISSING_ISSUES))
  fi
done < <(grep -oE '(frameworks|checklists)/[a-zA-Z0-9_-]+\.md' "$ROOT/SKILL.md" | sort -u)
(( MISSING_ISSUES == 0 )) && ok "All SKILL.md framework references resolve to files on disk"
# ─── Check 10: Frameworks on disk are indexed in SKILL.md ─────────────────────
head "Framework index coverage"
UNINDEXED_ISSUES=0
for file in "$ROOT/frameworks/"*.md; do
  name=$(basename "$file")
  if ! grep -q "$name" "$ROOT/SKILL.md"; then
    fail "Framework not indexed in SKILL.md: $name"
    ((++UNINDEXED_ISSUES))
  fi
done
(( UNINDEXED_ISSUES == 0 )) && ok "All framework files on disk are indexed in SKILL.md"

# ─── Check 11: README.md version badge matches SKILL.md ────────────────────────
head "README version badge"
README_VER=$(grep -oE 'version-[0-9]+\.[0-9]+\.[0-9]+-blue' "$ROOT/README.md" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
SKILL_VER2=$(grep -m1 '^version:' "$ROOT/SKILL.md" | sed 's/version: *//')
if [ "$README_VER" = "$SKILL_VER2" ]; then
  ok "README.md version badge ($README_VER) matches SKILL.md version"
else
  fail "README.md version badge ($README_VER) does not match SKILL.md ($SKILL_VER2)"
fi

# ─── Summary ──────────────────────────────────────────────────────────────────
echo
echo "════════════════════════════════════════════"
echo "  Results: $PASS passed · $FAIL failed"
echo "════════════════════════════════════════════"

if (( FAIL > 0 )); then
  echo
  echo "Findings:"
  for issue in "${ISSUES[@]}"; do echo "  • $issue"; done
  echo
  exit 1
else
  echo "  ✅ All checks passed — ready to merge"
  echo
  exit 0
fi