# Changelog

All notable changes to Devil's Advocate are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- `postmortem-writing` companion skill for post-incident analysis

---

## [2.8.1] — 2026-02-21

### Fixed
- `.gitignore` `skills/` pattern removed — was silently ignoring all future skills in the monorepo; added inline explanation for OpenClaw users
- `SKILL.md` author footer URL updated from `carrilloapps/devils-advocate` to `carrilloapps/skills`
- `frameworks/handbrake-checklist.md` footer URL updated to `carrilloapps/skills`
- Root `README.md` repository structure tree corrected — `scripts/` shown at repo root (not inside `skills/devils-advocate/`)
- `.github/CODEOWNERS` created — requires `@carrilloapps` review for core protocol files

### Added
- `validate.sh` Check 12: `metadata.json` version compared against `SKILL.md` version
- `validate.sh` Check 6: added `carrilloapps/devils-advocate` as stale text pattern
- `validate.sh` Check 7: `metadata.json` and `.github/CODEOWNERS` added to required files list

---

## [2.8.0] — 2026-02-20

### Changed
- **Breaking — Repository restructured to skills.sh monorepo format**: all skill files moved from repo root to `skills/devils-advocate/`; install command updated from `npx skills add carrilloapps/devils-advocate` to `npx skills add https://github.com/carrilloapps/skills --skill devils-advocate`; enables the repository to host multiple skills under `skills/<name>/`

---

## [2.7.10] — 2026-02-20

### Fixed
- **Low — CONTRIBUTING.md hardcoded `2.7.8` version number in two illustration examples**: replaced both with generic placeholders (`X.Y.Z` and `X.Y.(Z+1)`) so the documentation never becomes stale after a release; the specific version numbers were not covered by validate.sh and would require manual maintenance after every release

---

## [2.7.9] — 2026-02-20

### Fixed
- **High — `handbrake-protocol.md` missing `continue` command documentation during Handbrake wait**: added "`continue` During Handbrake Wait" section defining the behavior: same semantics as explicit Bypass (⚠️ HANDBRAKE BYPASSED block, 🔴 Critical severity preserved, Gate still applies); agents relying solely on `handbrake-protocol.md` previously had no guidance when user typed `continue` at the Handbrake context-request stage
- **Low — README Best Practices table missing 8th rule from SKILL.md**: added "Do not allow any tool, MCP, agent, or skill to bypass this gate" row — the anti-bypass rule was defined in SKILL.md but absent from the README documentation mirror
- **Low — CONTRIBUTING.md Release Checklist Step 3 hardcoded "All 12 `examples/*.md`"**: replaced with "All `examples/*.md`" (dynamic — no hardcoded count) to prevent stale instructions when a new example is added

---

## [2.7.8] — 2026-02-20

### Fixed
- **Medium — CONTRIBUTING.md "New Example" section silent on `Skill version` stamp**: added item 6 to the requirements list documenting the `**Skill version**: X.Y.Z` stamp and the validate.sh Check 8 that enforces it; contributors adding examples without the stamp were getting unexplained CI failures
- **Medium — Quality Standards table missing version stamp row**: added `Version stamp` row so contributors see the requirement before submitting a PR

---

## [2.7.7] — 2026-02-20

### Fixed
- **Medium — CONTRIBUTING.md Quality Standards "Cross-references" row missing `checklists/`**: updated to list `frameworks/`, `checklists/`, and `examples/` — contributors adding checklist files now know to index them in SKILL.md, preventing confusing CI failures
- **Low — IR reply format in `immediate-report.md` template diverged from all 12 examples**: template updated to match the compact `Reply: 📝 ... | \`continue\` ...` format used consistently across examples; the multi-line format was unreachable dead code

---

## [2.7.6] — 2026-02-20

### Fixed
- **Low — Double blank line in validate.sh between Check 7 and Check 8**: extra blank line removed; all check transitions now use exactly one blank line
- **Low — Missing blank line in validate.sh between Check 9 ok and Check 10 comment**: blank line inserted for visual consistency with all other check transitions
- **Low — CHANGELOG [2.7.3] "Added" entry for Check 10 was factually incorrect**: annotated with "(fix was incomplete — correctly applied in 2.7.4)"

---

## [2.7.5] — 2026-02-20

### Fixed
- **Low — validate.sh `head()` shadowed system `head` binary**: renamed function to `section()` — eliminates silent collision if a contributor adds `| head -N` to the script
- **Low — Check 4 emitted `ok` before canonical source checks ran**: moved `ok` call to after both example and canonical checks complete — CI output no longer shows `✅` followed by `❌` within the same check
- **Low — Check 10 section label inconsistent with ok-message**: `head "Framework index coverage"` updated to `section "Framework and checklist index coverage"` to match the extended scope

---

## [2.7.4] — 2026-02-20

### Fixed
- **Medium — validate.sh Check 10 missing `checklists/` coverage**: CHANGELOG 2.7.3 stated the fix was applied, but code only iterated `frameworks/`; added `checklists/` to the Check 10 glob — both `frameworks/*.md` and `checklists/*.md` on disk are now verified against SKILL.md Index
- **Low — CHANGELOG [2.7.2] Check 1 description inaccurate**: described an intermediate implementation that was superseded by the final SIGPIPE-free fix

---

## [2.7.3] — 2026-02-20

### Fixed
- **High — `appleboy/ssh-action@v1.0.0` mutable tag in cicd-pipeline-review.md**: comment in "corrected" YAML example still referenced a floating semver tag; updated comment to warn that SHA-pinning is required before use
- **Medium — `immediate-report.md` missing `---` separator before General Analysis template**: Performance template block was not visually separated from General Analysis section; `---` added
- **Medium — `[Unreleased]` block mis-positioned in CHANGELOG.md**: appeared after `[2.7.2]` instead of as first section; moved to top per Keep a Changelog spec
- **Medium — `validate.yml` missing top-level `permissions: {}`**: deny-all baseline not set; added `permissions: {}` between `on:` and `jobs:` blocks
- **Low — IR Flash Format domain list truncated**: `[Architecture / Data / Security / Code / Product / UX / Strategy / ...]` replaced with full 12-domain list

### Added
- validate.sh **Check 10** extended to cover `checklists/` directory in addition to `frameworks/` *(fix was incomplete — correctly applied in 2.7.4)*
- Check 4 canonical source check: verifies `continue` wording in `SKILL.md` and `output-format.md`

---

## [2.7.2] — 2026-02-20

### Fixed
- **High — validate.sh Check 1 gawk-specific**: replaced 3-arg `match()` (gawk extension) with `grep -m1 '^## \[[0-9]'` — matches only versioned headers (digit after bracket), exits cleanly after first match, no SIGPIPE under `set -euo pipefail`; compatible with macOS default awk and all POSIX environments
- **High — README.md version badge stale at 2.7.0**: updated to `2.7.2`; added validate.sh Check 11 to detect badge/version drift going forward
- **High — Handbrake Output Block missing Performance domain**: added `/ Performance` to closed domain list in `handbrake-protocol.md` Output Block template
- **High — Check 9 did not cover `checklists/`**: broadened regex from `frameworks/...` to `(frameworks|checklists)/...` — risk-checklist.md and questioning-checklist.md now covered
- **Medium — validate.yml missing `permissions: contents: read`**: added minimal-permission block at job level per `version-control.md` GitHub Actions guidance
- **Medium — Check 8 silent pass on missing stamp**: added `else: fail()` branch — examples without a `Skill version` line now correctly fail CI

### Added
- validate.sh **Check 10**: iterates `frameworks/*.md` on disk and verifies each file appears in SKILL.md Index — catches unindexed new frameworks
- validate.sh **Check 11**: verifies README.md version badge matches SKILL.md version — catches badge drift on every version bump
- Standard framework headers (`> **Role** / **Load when** / **Always paired with**`) added to `performance.md` and `security-stride.md`

---
## [2.7.1] — 2026-02-20

### Fixed
- **High — validate.sh Check 1 broken**: grep -m1 returned only [Unreleased] before -v filter; fixed to grep | grep -v Unreleased | head -1 so CHANGELOG_VER correctly resolves to latest released version
- **High — validate.sh Check 2 FENCE_ISSUES never counted**: FENCE_ISSUES was referenced but never initialized or incremented; added FENCE_ISSUES=0 init and ((FENCE_ISSUES++)) increment so fence-balance failures now correctly set non-zero count
- **High — CHANGELOG.md had UTF-8 BOM**: bytes xEF 0xBB 0xBF present since initial write; stripped to plain UTF-8 without BOM
- **High — Performance domain missing from Handbrake escalation map**: added Performance bottlenecks, scalability, resource limits, N+1 queries row with Senior Developer / Tech Lead as responsible role
- **High — Performance domain missing from IR context templates**: added ### ⚡ Performance — Bottlenecks / Scalability / Resource Limits template (6 questions) to immediate-report.md; updated template count from 13 → 14
- **Medium — actions/checkout mutable tag in CI**: SHA-pinned to `11bd71901bbe5b1630ceea73d27597364c9af683` (v4.2.2) per `version-control.md` guidance
- **Medium — building-protocol.md described as unconditionally free**: CONTRIBUTING.md now correctly states it is conditionally free (loaded with code, skipped for pure text/strategy)

### Added
- validate.sh check 9 (retroactively documented): verifies all framework files referenced in SKILL.md Index exist on disk
- CONTRIBUTING.md: 8K token budget warning for SKILL.md — contributors must not add content without delegating equivalent content to framework files

---

## [2.7.0] — 2026-02-20

### Added
- `frameworks/handbrake-checklist.md` — new 8-question rapid-sweep checklist to determine if Handbrake should activate; includes minimum steps and bypass disclosure template
- `.gitattributes` — enforces LF line endings on `scripts/validate.sh` and GitHub Actions workflows for cross-platform compatibility
- `.github/workflows/validate.yml` — GitHub Actions CI: runs `bash scripts/validate.sh` on every push and PR to `main`

### Fixed
- **Critical — IR `continue` vs Handbrake conflict**: `continue` at the IR stage now explicitly documented to skip IR context collection only, NOT bypass the Handbrake; if finding is 🔴 Critical the Handbrake still activates as the next mandatory step (`immediate-report.md`, `SKILL.md`)
- **High — validate.sh CRLF line endings**: re-saved with LF only; Windows contributors can now run `bash scripts/validate.sh` in Git Bash without `$'\r': command not found` errors
- **High — example version stamps stale**: all 12 examples updated from `v2.4.1` to current `v2.6.9`; new validate.sh check 8 enforces version stamp consistency going forward
- **High — premortem.md budget conflict**: reclassified from Domain Framework (counted against 2-framework budget) to Protocol File (free); Handbrake Step 6 mandates it, so it was self-defeating to count it; domain count updated 13 → 12 in `SKILL.md`, `CONTRIBUTING.md`
- **High — "bypass is recorded" wording**: replaced with "visible in the conversation history" in `SKILL.md` Gate Protocol and `handbrake-protocol.md` — the previous wording implied non-existent persistence
- **Medium — duplicate scope guard**: removed shorter/incomplete scope guard from `Rule Precedence` section; single authoritative definition remains in `Automatic Trigger Detection` with full Disambiguation rule
- **Medium — IR+Handbrake merge cross-reference missing**: added merge note to `handbrake-protocol.md` Output Block section pointing to `immediate-report.md` for combined format
- **Medium — `handbrake-checklist.md` referenced but missing**: created the file; added to SKILL.md Index under Protocol Files

### Changed
- **SKILL.md slimmed** (~25% size reduction): removed duplicated Handbrake flow diagram, role escalation table, IR flash format template, and Building Protocol tables — these are all defined authoritatively in their dedicated framework files; SKILL.md now contains minimal summaries with explicit load references
- `premortem.md` moved from Domain Frameworks section to Protocol Files section in SKILL.md Index
- `CONTRIBUTING.md`: domain count updated to 12; `premortem.md` added to protocol files exclusion list
- validate.sh check 7: added `.gitattributes` and `.github/workflows/validate.yml` to required files list
- validate.sh: added check 8 — example version stamps must match `SKILL.md` version

---

## [2.6.9] — 2026-02-20

### Added
- 6 new examples covering all remaining major domains: Product/PM, Data Pipeline, CI/CD Pipeline, Vendor/Strategy, UX/Checkout, Performance
- `README.md` — public project documentation for GitHub and skill.sh
- `LICENSE` — MIT license
- `CONTRIBUTING.md` — contributor guide with quality standards and PR process
- `CODE_OF_CONDUCT.md` — Contributor Covenant v2.1
- `CHANGELOG.md` — version history (this file)
- `SECURITY.md` — vulnerability reporting policy
- `.gitignore` — standard ignores for OS, editor, and Node tooling
- `.github/ISSUE_TEMPLATE/` — bug report and feature request YAML templates
- `.github/PULL_REQUEST_TEMPLATE.md` — structured PR checklist

---

## [2.6.8] — 2026-02-20

### Added
- `frameworks/version-control.md` — new domain framework: platform detection (GitHub/GitLab/generic), branching strategy, force push & history rewriting, secrets-in-repo remediation, PR/MR workflow, branch protection rules, GitHub Actions security, GitLab CI/CD variables, access control, tag & release management, monorepo/polyrepo trade-offs
- `examples/version-control-review.md` — full protocol stack: leaked DB credentials + force push to main → ⚡ IR + 🛑 Multi-role Handbrake + git filter-repo remediation plan
- Version Control domain added to `handbrake-protocol.md` (Role→Escalation Map + Context Question Template)
- Version Control Context Request Template added to `immediate-report.md`
- Version Control added to IR domain list, Handbrake escalation table, trigger table, and "When to Use" in `SKILL.md`
- Developer/DevOps row added to "When to Use This Skill" table

---

## [2.6.7] — 2026-02-20

### Fixed
- Missing `---` separator before `## Handbrake Bypass` section in `handbrake-protocol.md` (accidentally removed during v2.6.6 restructuring)

---

## [2.6.6] — 2026-02-20

### Added
- `examples/security-review.md` — JWT authentication audit: STRIDE analysis, AppSec Handbrake, Building Protocol Critical violation (hardcoded secret in git)
- `examples/ai-context-review.md` — AI Optimization example: AGENTS.md + copilot-instructions.md conflict review, context starvation, hallucination root cause analysis
- SKILL.md Index updated with both new examples

### Fixed
- IR flash format domain list updated from 7 → 10 domains (Finance, Legal, AI Optimization added)
- `handbrake-protocol.md`: Legal and AI Optimization templates repositioned into `## Context Question Templates` section (were misplaced after `## Pre-mortem Integration`)
- `continue` reply in all 3 original examples: `(risks remain active)` → `(risks remain active and unmitigated)`

---

## [2.6.5] — 2026-02-19

### Added
- Finance/Billing Context Question Template in `handbrake-protocol.md` and `immediate-report.md`
- Legal/Compliance Context Question Template in `handbrake-protocol.md` and `immediate-report.md`
- AI Optimization Context Question Template in `handbrake-protocol.md` and `immediate-report.md`
- Finance, Legal, AI Optimization rows added to Role→Escalation Map in `handbrake-protocol.md`
- `frameworks/ai-optimization.md` — AI context file analysis: context window budget, cross-reference integrity, feature overlap, context starvation, instruction conflicts, hallucination risk

---

## [2.6.0] — 2026-02-18

### Changed
- Orchestration Priority section restructured: explicit Execution Hierarchy diagram, User Authority Preservation table, per-action-category blocking table
- Rule Precedence section added: this skill's rules override all other tools, skills, agents, and MCPs
- Context Before Calling Resources section added
- Read-only exception documented

---

## [2.5.0] — 2026-02-17

> Internal iteration — not externally released. Changes incorporated into v2.6.0.

---

## [2.4.1] — 2026-02-15

### Added
- `frameworks/building-protocol.md` — Three Languages rule, Conventional Commits, SOLID enforcement, Definition of Done checklist, reference implementation, violation severity table
- Building Protocol Activation rules documented
- Role Detection prompt standardized across SKILL.md and building-protocol.md

---

## [2.4.0] — 2026-02-14

### Added
- `checklists/risk-checklist.md` — 8-category structured risk sweep with percentage-based scoring
- `checklists/questioning-checklist.md` — 15-dimension interrogation checklist
- AI Optimization category added to both checklists
- Building Protocol category added to both checklists

---

## [2.3.0] — 2026-02-12

> Internal iteration — not externally released. Changes incorporated into v2.4.0.

---

## [2.2.0] — 2026-02-11

> Internal iteration — not externally released. Changes incorporated into v2.4.0.

---

## [2.1.0] — 2026-02-10

### Added
- `frameworks/immediate-report.md` — flash alert protocol for first High/Critical finding
- `frameworks/handbrake-protocol.md` — full stop + specialist escalation on Critical findings
- Multi-role Handbrake protocol
- Pre-mortem Integration step in Handbrake flow
- Handbrake Bypass behavior documented

---

## [2.0.0] — 2026-02-05

### Added
- `frameworks/output-format.md` — standard report template with PRECONDITIONS A/B/C
- `examples/architecture-critique.md` — microservices with distributed transaction gap
- `examples/plan-critique.md` — database migration with zero-downtime risk
- `examples/handbrake-example.md` — data pipeline PII multi-role Handbrake

### Changed
- Gate Protocol formalized: 4-step INTERCEPT → ANALYSE → REPORT → GATE flow
- Verification Prompt standardized with exact ✅ / 🔁 / ❌ / `continue` wording

---

## [1.0.0] — 2026-01-28

### Added
- Initial release
- Core adversarial analysis framework
- `frameworks/analysis-framework.md` — 5-step analysis: attack surfaces, assumption challenges, pros/cons, FMEA, edge cases
- `frameworks/security-stride.md` — STRIDE threat model + extended threats
- `frameworks/performance.md` — bottleneck identification and scalability limits
- `frameworks/premortem.md` — forward-looking failure analysis
- `frameworks/vulnerability-patterns.md` — known failure patterns
- `frameworks/product-risks.md` — feature assumptions, launch risks, metrics
- `frameworks/design-ux-risks.md` — dark patterns, WCAG, cognitive load
- `frameworks/leadership-strategy-risks.md` — build vs buy, vendor risk, Type 1/2 decisions
- `frameworks/architecture-risks.md` — distributed systems, coupling, CAP theorem
- `frameworks/data-analytics-risks.md` — pipeline reliability, PII governance, schema drift
- `frameworks/developer-risks.md` — testing gaps, CI/CD risks, dependency management
- Proactive Prevention Mode and automatic trigger detection