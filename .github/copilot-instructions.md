# Copilot Instructions

This repository is the source for the **devil's advocate** skill — a mandatory adversarial analysis gate for 40+ AI coding agents.

## Devil's Advocate gate (required)

Before implementing any plan, proposal, or code change in this repository, load and apply:

```
skills/devils-advocate/SKILL.md
```

The skill runs **first** — before any file edit, refactor, or git operation. All actions require adversarial analysis and explicit user approval (`✅ Proceed`) before proceeding.

## Quality gate

Run before every commit:

```bash
bash scripts/validate.sh
```

All checks must pass.

## Conventions

- **Version cascade**: bump `version:` in `skills/devils-advocate/SKILL.md` frontmatter, then follow the cascade checklist in `.github/CONTRIBUTING.md`
- **Documentation**: `en_US` recommended; code identifiers always `en_US`
- **Commits**: Conventional Commits format (`feat:`, `fix:`, `docs:`)
- **Branch**: `main` only — enable branch protection in GitHub Settings → Branches (required status check: `validate`)
