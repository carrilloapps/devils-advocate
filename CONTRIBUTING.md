# Contributing to Devil's Advocate

Thank you for your interest in improving Devil's Advocate! This skill is built on the idea that adversarial thinking makes software better — and we apply that same principle to contributions: every proposal is welcome, and every concern will be heard.

---

## Table of Contents

- [What Can I Contribute?](#what-can-i-contribute)
- [Before You Start](#before-you-start)
- [Development Setup](#development-setup)
- [Contribution Types](#contribution-types)
  - [New Framework](#new-framework)
  - [New Example](#new-example)
  - [Improving Existing Files](#improving-existing-files)
  - [Bug Reports](#bug-reports)
- [Quality Standards](#quality-standards)
- [Pull Request Process](#pull-request-process)
- [Code of Conduct](#code-of-conduct)

---

## What Can I Contribute?

| Type | Welcome? | Notes |
|------|----------|-------|
| New domain framework (`frameworks/*.md`) | ✅ Yes | Must follow template structure; requires example |
| New example (`examples/*.md`) | ✅ Yes | Must show full protocol stack (IR + Gate minimum) |
| Improvements to existing frameworks | ✅ Yes | Keep scope tight; explain the improvement |
| Bug fixes (incorrect guidance, broken references) | ✅ Yes | Include evidence that the current text is wrong |
| Translations | ⚠️ Discuss first | Open an issue to coordinate |
| New checklists | ⚠️ Discuss first | High bar — must not overlap existing ones |
| Changes to core protocol files | ⚠️ Discuss first | `SKILL.md`, `output-format.md`, `handbrake-protocol.md`, `immediate-report.md` — open an issue first |

---

## Before You Start

1. **Search open issues** — your idea may already be in progress
2. **Open an issue first for large changes** — before writing a full framework or changing core protocol, discuss the scope
3. **Read the existing files** — especially `SKILL.md` and `frameworks/output-format.md` to understand the conventions

---

## Development Setup

No build tools required. This is a pure Markdown skill.

```bash
# Clone the repository
git clone https://github.com/carrilloapps/devils-advocate.git
cd devils-advocate

# Edit files using any Markdown editor
# Preview with any Markdown renderer (VS Code, GitHub preview, etc.)
```

---

## Contribution Types

### New Framework

A new framework file in `frameworks/` must:

1. **Follow the header convention**:
   ```markdown
   # [Framework Name]

   > **Role**: [Who should load this]
   > **Load when**: [Trigger conditions — be specific]
   > **Always paired with**: [Cross-references to related files, if any]
   ```

2. **Not duplicate** existing framework coverage — check all **12 existing domain frameworks**:
   Architecture · Security · Performance · Developer/Code · Data & Analytics · Product · UX/Design · Strategy/Leadership · AI Optimization · Version Control · Vulnerability Patterns · General Analysis

   > Protocol files (`output-format.md`, `handbrake-protocol.md`, `immediate-report.md`, `premortem.md`, `handbrake-checklist.md`) are always free and do not count toward the 12-domain budget. `building-protocol.md` is conditionally free: loaded at no cost when the analysis involves code; skipped for pure text or strategy reviews.
3. **Include an adversarial lens** — not just "here are best practices" but "here are the risks and how they fail"
4. **Be accompanied by a new example** in `examples/` that demonstrates the framework in use
5. **Be added to the Index** in `SKILL.md` under `### 📂 Domain Frameworks` — and update the count in that heading (currently `12 domains`) and in item 2 above
6. **Keep SKILL.md under 8,000 tokens** — it is always loaded in full by every agent. Currently ~7,068 tokens. Do not add content to SKILL.md without delegating equivalent content to a framework file first.

### New Example

An example file in `examples/` must:

1. **Start with the original proposal** (the thing being analyzed):
   ```markdown
   > **Original proposal (from [Role]):** [1–3 sentences describing what was proposed]
   ```

2. **Show the full protocol stack** where appropriate:
   - ⚡ Immediate Report (if a High or Critical finding is present — it should be)
   - 🛑 Handbrake (if a Critical finding is present)
   - Full report using `output-format.md` structure
   - Gate prompt (always, verbatim)

3. **Use the Gate prompt exactly as defined** in `SKILL.md`:
   ```
   ✅ Proceed   — continue with the approved action as planned
   🔁 Revise    — describe the change and I will re-analyse
   ❌ Cancel    — stop, do not implement
   `continue`   — proceed without addressing remaining issues (risks remain active and unmitigated)
   ```

4. **Cover a domain not already well-represented** in existing examples (check `examples/` before writing)

5. **Be added to the Index** in `SKILL.md` under `### 📂 examples/`

### Improving Existing Files

- Keep changes minimal and surgical
- Explain in the PR description what was wrong and why your version is better
- Do not change the Gate prompt wording, version stamps in examples, or core protocol flow without opening an issue first

### Bug Reports

Use the [Bug Report issue template](.github/ISSUE_TEMPLATE/bug_report.yml). A good bug report includes:

- The file and line number containing the incorrect guidance
- Why it is incorrect (citation, evidence, or clear reasoning)
- A suggested correction

---

## Quality Standards

All contributions must pass these checks before merge:

| Check | Requirement |
|-------|-------------|
| Fence balance | Every ` ``` ` opener has a matching closer |
| Gate prompt | Every example ends with the exact Gate prompt from `SKILL.md` |
| `continue` line | Must say `(risks remain active and unmitigated)` — not `(risks remain active)` |
| Cross-references | Any file added to `frameworks/`, `checklists/`, or `examples/` must be added to the `SKILL.md` Index |
| Domain coverage | New frameworks must not duplicate an existing domain |
| en_US identifiers | All code in examples follows the Building Protocol |
| No stale text | No references to `with implementation`, `14-dimension`, or other legacy phrasing |

The maintainers run an automated sweep script on every PR that checks all of the above. You can run it locally before submitting:

```bash
bash scripts/validate.sh
```

---

## Pull Request Process

1. **Branch naming**: `feat/<description>`, `fix/<description>`, `docs/<description>`
2. **Commit messages**: Conventional Commits format (`feat:`, `fix:`, `docs:`)
3. **PR title**: Same format as commit message
4. **PR description**: Fill in the PR template completely
5. **One concern per PR**: Don't combine a new framework with changes to core protocol

### Review turnaround

| PR type | Target review time |
|---------|-------------------|
| Bug fix (typo, broken reference) | 2–3 days |
| New example | 5–7 days |
| New framework | 7–14 days |
| Core protocol change | 14+ days (requires community discussion) |

### skill.sh listing

The [skills.sh/carrilloapps/devils-advocate](https://skills.sh/carrilloapps/devils-advocate) page activates automatically after the first `npx skills add carrilloapps/devils-advocate` is run. The README badge and install command are correct and will resolve once the skill is published. The skills.sh badge in the README may show a 404 until first publish — this is expected.

---

All contributors are expected to follow the [Code of Conduct](CODE_OF_CONDUCT.md). Be direct, be honest, be kind.