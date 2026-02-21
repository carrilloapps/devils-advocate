## Summary

<!-- One paragraph: what does this PR do and why? -->

## Type of Change

- [ ] 🐛 Bug fix — incorrect or misleading guidance corrected
- [ ] ✨ New example (`examples/*.md`)
- [ ] 📚 New framework (`frameworks/*.md`)
- [ ] 🔧 Improvement to existing framework or checklist
- [ ] 🏗️ Core protocol change (`SKILL.md`, `handbrake-protocol.md`, `immediate-report.md`, `output-format.md`)
- [ ] 📦 Project infrastructure (README, CI, templates, `AGENTS.md`, `copilot-instructions.md`)

## Changes Made

<!-- List the files changed and what was changed in each -->

| File | Change |
|------|--------|
| | |

## Quality Checklist

### All PRs
- [ ] All ` ``` ` code fences are balanced (every opener has a closer)
- [ ] No stale text: no `with implementation`, `14-dimension`, `carrilloapps/devils-advocate`, or other legacy phrasing
- [ ] All code identifiers in examples use `en_US` (Building Protocol)
- [ ] `bash scripts/validate.sh` runs with 0 failures locally
- [ ] Commit message follows Conventional Commits format

### If adding or modifying an example
- [ ] Example ends with the exact Gate prompt (✅ Proceed / 🔁 Revise / ❌ Cancel / `continue`)
- [ ] `continue` line reads: `proceed without addressing remaining issues (risks remain active and unmitigated)`
- [ ] Example added to the `SKILL.md` Index under `### 📂 examples/`
- [ ] Example covers a scenario not already covered by existing examples

### If adding a new framework
- [ ] File added to `SKILL.md` Index under `### 📂 Domain Frameworks`
- [ ] Framework does not duplicate an existing domain
- [ ] Matching example added to `examples/`
- [ ] Framework follows the header convention (Role, Load when, Always paired with)

### If modifying core protocol files
- [ ] Issue was opened and discussed before this PR
- [ ] All cross-references are updated (SKILL.md, any file referencing the changed section)
- [ ] Version bumped in `SKILL.md` frontmatter

## Testing

<!-- How did you verify these changes are correct? (e.g., "Read all related files for cross-reference accuracy", "Ran the automated sweep script") -->

## Related Issues

<!-- Closes #issue-number (if applicable) -->
