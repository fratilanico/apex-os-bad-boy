# APEX OS Bad Boy

> "Everything you need. Nothing you don't. Mastery at your fingertips."

The ultimate agent productivity system with 45+ skills, intelligent recommendations, risk-based planning, and systematic workflows.

## Installation

```bash
# Install with npx (works with Claude Code, Cursor, Cline, etc.)
npx skills add fratilanico/apex-os-bad-boy

# Or clone directly
git clone https://github.com/fratilanico/apex-os-bad-boy.git ~/.agents/skills/apex-os-bad-boy
```

## What Is This?

APEX OS Bad Boy is a comprehensive productivity system for AI agents that teaches:

1. **WHEN** to use each skill (75%+ accuracy recommendation)
2. **HOW** to structure work based on risk level
3. **WHY** certain approaches lead to better outcomes

## Core Features

### 1. Risk Level Selector

Choose the right approach for each task:

| Mode | Use For | Workflow |
|------|---------|----------|
| **SAFE** | Production, auth, payments | Design → Plan → TDD → Code → Review → Deploy |
| **MID** | Bug fixes, small features | Quick Plan → Code → Review → Ship |
| **RISKY** | POCs, experiments | Just Do It → Ship → Fix |

### 2. Skill Recommendation Engine

45+ skills organized by tier:

| Tier | Skills |
|------|--------|
| CRITICAL | brainstorming, writing-plans, verification, security |
| HIGH | TDD, debugging, React, Supabase, subagents |
| MEDIUM | Docker, animations, UI components, browser |
| LOW | Documentation, architecture |

### 3. Systematic Workflows

Pre-defined paths for every situation:
- SAFE MODE: Full process with design, planning, TDD, review
- MID MODE: Fast iteration with quick checks
- RISKY MODE: Maximum velocity for experiments

## Skills Included

### Meta Process
- brainstorming, writing-plans, verification, code review
- subagent-driven-development, recursive-agent-coordination

### Frontend
- vercel-react-best-practices, web-design-guidelines
- shadcn-master, framer-motion-best-practices
- performance-optimization, nextjs-master

### Backend
- supabase-expert, docker-best-practices
- security-best-practices

### Quality
- tdd-master, systematic-debugging

### Specialty
- browser-use, agent-browser, c4-documentation
- using-git-worktrees, finishing-a-development-branch

## Quick Start

### 1. Choose Your Risk Level

Before any task, answer:

1. **Impact if breaks?** (Production / Dev / Easy to fix)
2. **Complexity?** (Multi-component / Single / Simple)
3. **Understanding?** (New territory / Known / Clear)

### 2. Follow the Workflow

```
SAFE:  brainstorming → writing-plans → tdd-master → verify → review → deploy
MID:   quick plan → implement → review → ship
RISKY: just do it → ship → fix
```

### 3. Always Invoke

- ✅ brainstorming for new features
- ✅ verification-before-completion before claiming done
- ✅ receiving-code-review before merge

## Documentation

- **SKILL.md** - Complete skill reference with decision matrix
- **APEX-OS-MANUAL.md** - End-user manual
- **AGENTS.md** - Full agent protocol (in parent directory)

## Skills Source

This skill integrates best practices from:

- Vercel Engineering (React/Next.js)
- Supabase (Database/Auth)
- browser-use (Automation)
- OpenCode (Agent coordination)
- Top open source AI agent frameworks

## Requirements

- OpenCode, Claude Code, Cursor, Cline, or any SKILL.md-compatible agent
- Optional: `browser-use` CLI for browser automation

```bash
# Install browser-use (optional)
pip3 install "browser-use[cli]"
```

## Support

- GitHub: https://github.com/fratilanico/apex-os-bad-boy
- Issues: Open an issue on GitHub

---

*"If it's not spectacular, why do it?"*
