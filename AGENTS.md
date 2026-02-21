# AGENTS.md

This repository is the source for the **devil's advocate** skill — a mandatory adversarial analysis gate for 40+ AI coding agents.

## Devil's Advocate gate (required)

Before proposing or implementing **any** change to this repository, load and apply:

```
skills/devils-advocate/SKILL.md
```

The skill runs **first** — before any file edit, refactor, or git operation. All actions require a full adversarial analysis and explicit user approval (`✅ Proceed`) before proceeding. This includes changes to `SKILL.md`, `frameworks/`, `checklists/`, `examples/`, `scripts/`, and all root files.

## Quality gate

Run before every commit:

```bash
bash scripts/validate.sh
```

All checks must pass before pushing to `main`.

## Release conventions

Version bumps require a full cascade — see `.github/CONTRIBUTING.md` → "Releasing a New Version" for the complete checklist.
