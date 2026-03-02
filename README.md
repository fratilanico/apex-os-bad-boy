<div align="center">

```
╔══════════════════════════════════════════════════════════════════╗
║   ██████╗  █████╗ ██████╗     ██████╗  ██████╗ ██╗   ██╗       ║
║   ██╔══██╗██╔══██╗██╔══██╗    ██╔══██╗██╔═══██╗╚██╗ ██╔╝       ║
║   ██████╔╝███████║██║  ██║    ██████╔╝██║   ██║ ╚████╔╝        ║
║   ██╔══██╗██╔══██║██║  ██║    ██╔══██╗██║   ██║  ╚██╔╝         ║
║   ██████╔╝██║  ██║██████╔╝    ██████╔╝╚██████╔╝   ██║          ║
║   ╚═════╝ ╚═╝  ╚═╝╚═════╝     ╚═════╝  ╚═════╝    ╚═╝          ║
║                                                                  ║
║              A P E X   O S   ·   B A D   B O Y                  ║
╚══════════════════════════════════════════════════════════════════╝
```

**Drop-in skill bundles that turn your AI agent into a production-grade engineer.**

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](LICENSE)
[![Skills](https://img.shields.io/badge/skills-32-8b5cf6?style=flat-square)](#skills)
[![Bonus](https://img.shields.io/badge/bonus-sovereign--governance-f59e0b?style=flat-square)](#bonus-sovereign-governance)
[![Works with](https://img.shields.io/badge/Claude%20Code-supported-cc785c?style=flat-square)](https://claude.ai)
[![Works with](https://img.shields.io/badge/OpenCode-supported-0ea5e9?style=flat-square)](https://opencode.ai)
[![Skills Marketplace](https://img.shields.io/badge/more%20skills-skills.infoacademy.uk-ff8c00?style=flat-square)](https://skills.infoacademy.uk)

</div>

---

Plain markdown files. No framework. No CLI. No vendor lock-in.

Drop them into your agent's skills folder and it immediately knows how to debug, plan, deploy, and ship — the same way we do running a 6-agent autonomous swarm in production.

---

## Install

```bash
git clone https://github.com/fratilanico/apex-os-bad-boy.git

# Claude Code
cp -r apex-os-bad-boy/* ~/.claude/skills/

# OpenCode
cp -r apex-os-bad-boy/* ~/.config/opencode/skills/

# Cursor / Cline → copy to your project's rules or skills folder
```

No config. No imports. No setup. Your agent reads them automatically.

---

## Skills

32 skills across 7 categories. All free. All MIT.

### Process — how to work

| Skill | What it does |
|---|---|
| `brainstorming` | Explore intent and requirements before touching code. Prevents building the wrong thing. |
| `writing-plans` | Turn specs into executable phase plans with dependency analysis. |
| `executing-plans` | Run plans with atomic commits, deviation handling, and checkpoints. |
| `dispatching-parallel-agents` | Decompose independent tasks across parallel worker agents. |
| `subagent-driven-development` | Orchestrate multi-agent pipelines with review gates. |
| `context-window-stewardship` | Manage context rot in long sessions. Know what to load vs leave in files. |
| `verification-before-completion` | Demand evidence before claiming anything works. No more "it should work". |

### Quality — how not to break things

| Skill | What it does |
|---|---|
| `systematic-debugging` | Scientific method for bugs. Hypothesis → test → confirm. Never guess. |
| `test-driven-development` | Write failing tests first. Every time. No exceptions. |
| `code-edit-quality` | Precise SEARCH/REPLACE patterns. Accurate file modifications. |
| `tool-definition-patterns` | Standards for defining AI agent tools — typing, docs, safety. |
| `nextjs-production-bug-audit` | 26-point checklist for Next.js sites before they go live. |

### Frontend — the React/Next.js stack, done right

| Skill | What it does |
|---|---|
| `vercel-react-best-practices` | Rendering, re-render prevention, async patterns, server components. |
| `vercel-react-native-skills` | Lists, animations, gestures, native modules. Expo and bare. |
| `vercel-composition-patterns` | Compound components, context interfaces, explicit variants. |
| `framer-motion-best-practices` | Hardware-accelerated animations. Layout, gestures, scroll, SVG. |
| `shadcn-master` | Shadcn/ui + Radix + Tailwind patterns for enterprise apps. |
| `web-design-guidelines` | Accessibility, layout, typography, spacing. The fundamentals. |
| `nextjs-master` | App Router, Server Components, Supabase integration, TypeScript. |
| `ui-ux-pro-max` | 50 styles, 21 palettes, 50 font pairings. Full design system intelligence. |
| `performance-optimization` | Core Web Vitals, bundle analysis, React profiling. |

### Webtricks — specialized interactive UI

| Skill | What it does |
|---|---|
| `webtricks-animated-pipeline` | SVG circuit animations with traveling dots. Framer Motion + SVG. |
| `webtricks-browser-qa-audit` | Playwright-based QA. Screenshots, accessibility snapshots, interactive testing. |
| `webtricks-tier-pricing-ui` | Tier selectors, lock/unlock states, progressive disclosure. |

### Backend — data, infra, security

| Skill | What it does |
|---|---|
| `supabase-expert` | RLS policies, Auth flows, Storage, Edge Functions, real-time. |
| `docker-best-practices` | Image optimization, multi-stage builds, production hardening. |
| `security-best-practices` | XSS, CSRF, auth, API security. The non-negotiables. |

### AI & Agents — build agents that actually work

| Skill | What it does |
|---|---|
| `react-agent-loop` | ReAct reasoning loops, tool use, memory, avoiding infinite loops. |
| `prompt-engineering-apex` | System prompt design, CoT/ToT patterns, JSON schema enforcement. |
| `rag-retrieval-patterns` | Hybrid BM25 + dense retrieval, reranking, grounding LLM answers. |
| `skill-creator` | Create and package new skills. The meta-skill. |

---

## Bonus: `sovereign-governance`

> The cherry on top. Not part of the 32 — it's extra.

A complete multi-repo AI agent governance system. One `AGENTS.md` to rule them all.

Enforces single source of truth, pointer-based sync, state file standards, skills deduplication, and cross-repo compliance. If you're running more than one agent or more than one repo, this is the scaffolding that keeps everything from collapsing into chaos.

Built to govern the APEX OS swarm across 49 repositories. Included here because it's too useful to gate.

---

## How it works

Each skill is a `SKILL.md` file (plus supporting references where needed). Your agent reads it automatically when it's in the skills folder — no imports, no tool calls, no config.

```
~/.claude/skills/
├── brainstorming/
│   └── SKILL.md                   ← agent reads this before planning anything
├── systematic-debugging/
│   └── SKILL.md                   ← agent reads this when it hits a bug
├── vercel-react-best-practices/
│   ├── SKILL.md
│   └── rules/                     ← reference docs embedded by the skill
│       └── ...
└── sovereign-governance/          ← BONUS: multi-repo governance
    ├── SKILL.md
    └── ...
```

Works with Claude Code, OpenCode, Cursor, Cline, or any agent that supports skill/rule files.

---

## Want more?

This is the free tier. The full library goes deeper.

| Tier | Skills | What's extra |
|---|---|---|
| **Free** · this repo | 32 + bonus | Everything above. Forever. MIT. |
| **Builder** · $49 | 49 | Unpublished agent-ops internals. APEX OS setup playbook. Config templates. |
| **Operator** · $199 | 80 | Exact production stack running our live 6-agent swarm. Quarterly drops. Onboarding call. Skill audit. |
| **Enterprise** · custom | Full library | White-label. Bespoke builds. Dedicated support. SLA. |

→ **[skills.infoacademy.uk](https://skills.infoacademy.uk)**

---

## License

MIT — use it, fork it, build on it, sell products with it.

Built while running a 6-agent autonomous swarm in production.
These aren't tutorials. They're the real thing.
