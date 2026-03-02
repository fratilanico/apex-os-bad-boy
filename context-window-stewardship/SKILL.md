---
name: context-window-stewardship
description: "Use when context window is filling up, when agent responses degrade in quality over a long session, when deciding what to load into an agent's context vs keep in files, or when designing multi-agent systems where subagents need isolated contexts. Triggers on: context full, context rot, compaction, session degradation, token limit."
tier: FULL
tags: [context, tokens, compaction, progressive-disclosure, memory, subagents, apex-os]
source: DeepLearning.AI Agent Skills course + HandsOnLLM
last-updated: 2026-02-27
---

# Context Window Stewardship — APEX OS Standard

## Overview

Context window = a public good. Every token added degrades the space available
for reasoning. The goal is maximum signal per token. Context rot is real.

## The 3-Stage Loading Hierarchy (APEX OS Standard)

```
┌─────────────────────────────────────────────────────────────────────────┐
│ Stage 1 — Always in context (name + description only)                   │
│ → Agent uses this to decide WHETHER to load the skill                   │
│ → Hard limit: 2 lines. Never exceed.                                    │
├─────────────────────────────────────────────────────────────────────────┤
│ Stage 2 — Loaded on trigger (full SKILL.md body)                        │
│ → Loaded when skill description semantically matches the task           │
│ → Hard limit: 500 lines                                                 │
│ → Overflow → move to references/                                        │
├─────────────────────────────────────────────────────────────────────────┤
│ Stage 3 — Loaded on demand (references/, scripts/, assets/)             │
│ → Only when workflow explicitly needs them                              │
│ → Never inline large lookup tables or templates in SKILL.md            │
└─────────────────────────────────────────────────────────────────────────┘
```

## What Belongs Where

```
┌──────────────────────────────────┬──────────────────────────────────────┐
│ Content                          │ Location                             │
├──────────────────────────────────┼──────────────────────────────────────┤
│ Skill name + trigger description │ SKILL.md frontmatter (Stage 1)       │
│ Core workflow steps (≤500 lines) │ SKILL.md body (Stage 2)              │
│ Lookup tables > 20 rows          │ references/lookup.md (Stage 3)       │
│ Output format templates          │ assets/template.md (Stage 3)         │
│ Executable scripts               │ scripts/run.sh (Stage 3)             │
│ Session logs / project artifacts │ NOT IN SKILLS — wrong place          │
│ Personal documents               │ NOT IN SKILLS — wrong place          │
│ Large reference docs (>500 lines)│ NOT IN SKILLS — use RAG instead      │
└──────────────────────────────────┴──────────────────────────────────────┘
```

## Subagent Exception (CRITICAL)

```
┌─────────────────────────────────────────────────────────────────────────┐
│ Main agent:  Progressive disclosure applies.                            │
│              name+desc → SKILL.md → references on demand               │
│                                                                         │
│ ⚠️  Subagent:  ENTIRE SKILL.md is pre-loaded at dispatch.              │
│              No progressive disclosure. No on-demand loading.           │
│              Subagents do NOT inherit parent skills.                    │
│              Skills must be explicitly assigned to each subagent.       │
└─────────────────────────────────────────────────────────────────────────┘
```

## GSD's Solution to Context Rot

GSD (get-shit-done, `gsd-build/get-shit-done`) solves context rot by running
each plan in a **fresh 200k context subagent**. The orchestrator stays lean.

```
┌──────────────────────────────────────────────────────────────────────┐
│ Pattern: Orchestrator stays lean, workers get fresh context          │
│                                                                      │
│  Main session (30-40% context)                                       │
│         │                                                            │
│         ├──→ Subagent A (200k fresh) → executes Plan 1 → commits   │
│         ├──→ Subagent B (200k fresh) → executes Plan 2 → commits   │
│         └──→ Subagent C (200k fresh) → executes Plan 3 → commits   │
│                                                                      │
│  Result: No context rot. Quality stays high across 10+ plans.       │
└──────────────────────────────────────────────────────────────────────┘
```

## Context Budget Guidelines

```
┌──────────────────────────────┬──────────────────────────────────────┐
│ Item                         │ Target budget                        │
├──────────────────────────────┼──────────────────────────────────────┤
│ System prompt                │ < 2,000 tokens                       │
│ Skills loaded (per session)  │ < 5,000 tokens total                 │
│ Working memory               │ < 20% of context window              │
│ Single SKILL.md file         │ < 500 lines (~3,000 tokens)          │
│ Subagent task prompt         │ < 1,000 tokens                       │
└──────────────────────────────┴──────────────────────────────────────┘
```

## Session Compaction Signs (time to compact or hand off)

- Agent starts repeating itself or forgetting recent instructions
- Response quality degrades noticeably mid-session
- Agent references stale information from much earlier in session
- Context shows > 70% utilisation

## Common Mistakes

- Loading all skills at session start — kills context budget immediately
- Putting large lookup tables in SKILL.md body — move to references/
- Not assigning skills explicitly to subagents (they don't inherit)
- Fighting context rot by repeating instructions — spawn fresh subagent instead
