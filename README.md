# 🛠️ carrilloapps/skills

> Agent skills for AI coding agents — adversarial analysis, quality gates, and engineering best practices.
> Compatible with **GitHub Copilot, Claude Code, Cursor, Windsurf, Cline, Codex, Gemini CLI** and 40+ more.

[![License: MIT](https://img.shields.io/badge/License-MIT-red.svg)](LICENSE)
[![skills.sh](https://img.shields.io/badge/skills.sh-carrilloapps-black.svg)](https://skills.sh/carrilloapps/skills)
[![GitHub](https://img.shields.io/badge/GitHub-carrilloapps-181717.svg?logo=github)](https://github.com/carrilloapps/skills)
[![X / Twitter](https://img.shields.io/badge/@carrilloapps-000000.svg?logo=x)](https://x.com/carrilloapps)

---

## Available Skills

| Skill | Description | Version | Domains |
|-------|-------------|---------|---------|
| [🔴 **devils-advocate**](skills/devils-advocate/) | Mandatory adversarial risk gate — intercepts every plan before execution, blocks all actions until you explicitly approve | [![Version](https://img.shields.io/badge/v2.8.2-blue.svg)](skills/devils-advocate/CHANGELOG.md) | Architecture · Security · Performance · Data · Product · UX · Strategy · 12 total |

---

## Quick Install

```bash
# Install a specific skill
npx skills add carrilloapps/skills@devils-advocate

# Install all skills
npx skills add carrilloapps/skills
```

### Target a specific agent

```bash
npx skills add carrilloapps/skills@devils-advocate -a github-copilot
npx skills add carrilloapps/skills@devils-advocate -a claude-code
npx skills add carrilloapps/skills@devils-advocate -a cursor
npx skills add carrilloapps/skills@devils-advocate -a windsurf
```

### Global install (all your projects)

```bash
npx skills add carrilloapps/skills@devils-advocate -g
```

---

## Skill Details

### 🔴 [Devil's Advocate](skills/devils-advocate/)

> The mandatory adversarial analysis gate for 40+ AI coding agents — runs first, before any action.

AI tools are increasingly capable of executing complex, multi-step operations — creating files, calling APIs, running migrations, deploying services. Devil's Advocate adds the adversarial voice that asks: **"Should we?"**

**What it does:**

1. **Intercepts** every plan, proposal, or action — before executing
2. **Analyses** across 12 risk domains using specialized frameworks
3. **Fires alerts** mid-sweep on the first High or Critical finding
4. **Gates** all actions — nothing executes without your explicit `✅ Proceed`

**Protocol stack:**

| Protocol | Trigger | Effect |
|----------|---------|--------|
| ⚡ Immediate Report | First 🟠 High or 🔴 Critical finding | Flash alert + context request mid-sweep |
| 🛑 Handbrake | Any 🔴 Critical finding | Full stop + specialist escalation |
| 📄 Full Report | After context or `continue` | Structured adversarial analysis |
| 🚦 Gate | After full report | Waits for ✅ / 🔁 / ❌ |

**12 domains covered:** Architecture · Security · Performance · Developer/Code · Data & Analytics · Product · UX/Design · Strategy · AI Optimization · Version Control · Vulnerability Patterns · General Analysis

→ Full documentation: [`skills/devils-advocate/README.md`](skills/devils-advocate/README.md)

---

## Repository Structure

```
carrilloapps/skills/
├── scripts/
│   └── validate.sh         ← CI quality gate (46 checks)
└── skills/
    └── devils-advocate/    ← install: npx skills add carrilloapps/skills@devils-advocate
        ├── SKILL.md        ← always loaded by agents
        ├── README.md       ← full documentation
        ├── CHANGELOG.md    ← version history
        ├── metadata.json   ← skill metadata
        ├── frameworks/     ← 18 domain & protocol frameworks
        ├── checklists/     ← 2 structured risk checklists
        └── examples/       ← 12 real-world analysis examples
```

Each skill is self-contained and independently installable via `@<skill-name>`.

---

## Contributing

See [CONTRIBUTING.md](.github/CONTRIBUTING.md) for how to add new skills or improve existing ones.
Please read [CODE_OF_CONDUCT.md](.github/CODE_OF_CONDUCT.md) before contributing.
Security issues → [SECURITY.md](.github/SECURITY.md).

---

## License

[MIT](LICENSE) — free to use, modify, and distribute. Attribution appreciated.

---

*Built by [José Carrillo](https://carrillo.app) · [carrillo.app](https://carrillo.app)*

[![Website](https://img.shields.io/badge/website-carrillo.app-FF5733.svg)](https://carrillo.app)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-carrilloapps-0A66C2.svg?logo=linkedin)](https://linkedin.com/in/carrilloapps)
