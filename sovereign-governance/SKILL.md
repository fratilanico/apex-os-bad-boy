---
name: sovereign-governance
description: "Sovereign artifact governance for multi-repo AI agent ecosystems. One AGENTS.md to rule them all — enforces single source of truth, pointer-based sync, state file standards, skills deduplication, and cross-repo compliance. Use when creating repos, auditing governance, resolving AGENTS.md conflicts, or onboarding new agents."
tier: CRITICAL
tags: [governance, agents-md, multi-repo, compliance, enforcement, state-management, skills-governance, cross-repo, artifact-registry]
version: "1.0"
---

# Sovereign Governance

> "One source of truth. Everything else is a pointer."

---

## Overview

This skill enforces a unified governance model across a multi-repo AI agent ecosystem. It solves **governance drift** — where `AGENTS.md` files, state files, and skills duplicate across repositories, diverge over time, and cause agents to follow conflicting rules.

### The Problem

When multiple repositories each contain their own `AGENTS.md`, those files inevitably diverge. Agent A in repo-1 follows version X of the rules. Agent B in repo-3 follows version Y. Neither knows the other exists. Conflicts are discovered only when something breaks.

The same problem applies to state files (every repo invents its own format) and skills (duplicated across directories with different versions).

### The Solution

```
canonical-location/AGENTS.md        <- ONE file. All governance lives here.
        |
        |-- repo-1/AGENTS.md        <- 36-line pointer ("go read the canonical")
        |-- repo-2/AGENTS.md        <- 36-line pointer
        |-- repo-3/AGENTS.md        <- 36-line pointer
        |-- repo-N/AGENTS.md        <- 36-line pointer
        '-- [new repo]/AGENTS.md    <- 36-line pointer (auto-generated)
```

One canonical governance file lives **above** all repositories — not inside any single repo. Every repository contains a small pointer file that directs agents to the canonical source. Automated enforcement (shell scripts, git hooks) catches drift before it spreads.

### Key Design Decisions

1. **The canonical file lives outside any single repo.** This prevents one repo from becoming a dependency for every other repo. It also means the canonical can be edited without triggering CI in unrelated repos.

2. **Pointers are plain text, not symlinks.** Symlinks break across machines, CI environments, and independent clones. Pointer files are readable everywhere and carry repo-specific metadata.

3. **Governance is centralized. Documentation is not.** Only `AGENTS.md`, state file schemas, and skill standards are unified. Architecture docs, session logs, and READMEs stay per-repo where the work happens.

4. **Enforcement is automated.** A shell script audits all repos. A git hook blocks stale commits. Shell aliases provide quick access from any terminal.

---

## When to Invoke This Skill

An agent MUST invoke this skill when any of the following apply:

| Situation | Required Action |
|-----------|----------------|
| **Creating a new repository** | Generate an `AGENTS.md` pointer using the template |
| **Opening a repository for the first time in a session** | Verify `AGENTS.md` is a valid pointer, not a stale full copy |
| **Detecting `AGENTS.md` longer than the configured threshold** | Flag as governance violation; follow the canonical version instead |
| **Modifying any governance rules** | Edit ONLY the canonical file; never edit repo-level copies |
| **Adding a new skill** | Check all skill directories for duplicates before creating |
| **Creating or modifying state files** | Follow the `.agent_sync_state.json` schema defined in this skill |
| **Running a governance audit** | Use the enforcement script |
| **Onboarding a new agent, tool, or team member** | Point them to the canonical `AGENTS.md` |
| **Encountering conflicting instructions between repos** | The canonical file wins. Always. No exceptions. |
| **Closing a work session** | Update session state and agent sync state for handoff |

---

## Configuration

This skill uses environment variables so it works on any machine. Set these in your shell profile (`~/.zshrc`, `~/.bashrc`, `~/.profile`):

```bash
# Required: absolute path to your ONE canonical AGENTS.md
export SOVEREIGN_CANONICAL="$HOME/governance/AGENTS.md"

# Optional: parent directory to scan for repos (default: $HOME)
export SOVEREIGN_HOME="$HOME"

# Optional: max lines for a valid pointer file (default: 50)
export SOVEREIGN_MAX_LINES=50
```

If `SOVEREIGN_CANONICAL` is not set, the enforcement script will look for it at `$HOME/governance/AGENTS.md` as a fallback.

### Where to Put the Canonical File

The canonical `AGENTS.md` should live **above** all repositories. Good locations:

| Location | When to Use |
|----------|-------------|
| `~/governance/AGENTS.md` | Dedicated governance directory. Clean separation. |
| `~/archive/AGENTS.md` | If you already have a personal knowledge archive. |
| `~/AGENTS.md` | Simplest. Works if you don't mind it in your home root. |

**Do NOT put it inside a repo.** This creates a circular dependency — other repos depend on that repo existing and being cloned. If someone clones repo-3 without repo-1, they can't find the canonical.

---

## The Pointer Model

### What a Pointer File Looks Like

Every non-canonical repository has an `AGENTS.md` that looks like this:

```markdown
# AGENTS.md — POINTER FILE

**DO NOT add governance rules to this file.**
**DO NOT duplicate protocol from the canonical source.**

## Canonical Source

All agent protocol, governance, skills, coordination, and compliance rules
live in ONE place:

    /path/to/canonical/AGENTS.md

**Location:** Name of canonical location
**Authority:** Owner Name (Role)

## This Repo

| Field | Value |
|-------|-------|
| **Repo** | `repo-name` |
| **Purpose** | What this repo does |
| **Governance Level** | SOVEREIGN / STRATEGIC / TACTICAL / OPERATIONAL |
| **Status** | ACTIVE / REFERENCE / ARCHIVED |

## What To Do

1. Open the canonical AGENTS.md
2. Read it. Follow it.
3. If a rule here conflicts with the canonical — canonical wins. Always.

---

*This is a pointer file. The canonical AGENTS.md is at [location].*
*Last synced: YYYY-MM-DD*
```

A ready-to-use template is provided at `templates/AGENTS.md.template`.

### How Agents Process Pointers

When an agent opens a repository and reads `AGENTS.md`:

```
STEP 1: Check file size
        -> If < SOVEREIGN_MAX_LINES (default 50): likely a pointer
        -> If >= SOVEREIGN_MAX_LINES: likely a full copy (potential violation)

STEP 2: Check for "POINTER FILE" marker
        -> If present: confirmed pointer. Follow it.
        -> If absent: not a pointer. Flag as potential violation.

STEP 3: Check for canonical reference
        -> If canonical path is referenced: follow it, read the canonical
        -> If not referenced: violation. Use canonical directly.

STEP 4: Read the canonical AGENTS.md
        -> This is the authority. Follow all rules defined here.
```

### Detection Logic

A file is a valid pointer if ALL three conditions are met:

1. Line count < configured threshold (default 50)
2. File contains the string "POINTER FILE"
3. File references the canonical location

This is deliberately simple. No complex parsing. No frontmatter validation. Short file + says it's a pointer + points to the right place = compliant.

---

## Governance Levels

Every repository is classified by how sensitive its artifacts are:

| Level | Authority | Who Can Modify | Use For |
|-------|-----------|----------------|---------|
| **SOVEREIGN** | Absolute | Owner only | Core infrastructure, primary APIs, the canonical AGENTS.md itself |
| **STRATEGIC** | High | Owner + Lead Agent | Architecture repos, planning repos, investor-facing repos |
| **TACTICAL** | Medium | Assigned Agent | Feature repos, dashboards, tools, utility repos |
| **OPERATIONAL** | Standard | Any Agent | Archived repos, experiments, POCs, scratch repos |

The governance level determines:
- Who is allowed to modify files in that repo
- How strictly changes must be reviewed
- What the enforcement script reports when generating pointers

---

## Artifact Classification

Every file in the ecosystem is classified by sensitivity:

| Classification | Authority | Examples |
|---------------|-----------|----------|
| **SOVEREIGN** | Absolute — Owner only | The canonical `AGENTS.md`, root config files (`tsconfig.json`, `vercel.json`, `.env.example`) |
| **STRATEGIC** | High — Owner + Lead | Architecture docs, implementation plans, artifact registries, deployment configs |
| **TACTICAL** | Medium — Assigned Agent | Component specs, API designs, skill SKILL.md files, feature documentation |
| **OPERATIONAL** | Standard — Any Agent | `.agent_sync_state.json`, session logs, task boards, status reports |

### Modification Rules

| Artifact Classification | Modification Policy |
|------------------------|-------------------|
| SOVEREIGN | Owner approval required. No agent may modify without explicit instruction from the owner. |
| STRATEGIC | Review required. Changes must be documented in the decision log. |
| TACTICAL | Standard workflow. Assigned agent can modify as part of their task. |
| OPERATIONAL | Updated freely during work. No approval needed. |

---

## State File Standard

### The Problem with State Files

Without a standard, every repo invents its own state format. You end up with files like:
- `.agent_sync_state.json` (one schema)
- `.neural-sync-state.json` (different schema)
- `.agent_live_connection.json` (yet another schema)
- `.agent_recursive_coordination.json` (and another)

Agents can't read state across repos because every file is different.

### The Standard Schema: `.agent_sync_state.json`

Every active repository MUST have a `.agent_sync_state.json` at root following this schema:

```json
{
  "$schema": "sovereign-agent-sync-v3",

  "session": {
    "id": "string — unique session identifier (e.g. session-2026-02-16-001)",
    "started_at": "ISO 8601 timestamp",
    "mode": "NORMAL | EMERGENCY | SAFE_MODE"
  },

  "orchestrator": {
    "agent": "string — name of the orchestrating agent",
    "status": "ACTIVE | STANDBY | OFFLINE",
    "last_heartbeat": "ISO 8601 timestamp"
  },

  "current_mission": {
    "name": "string — human-readable mission name",
    "priority": "P0 | P1 | P2 | P3",
    "target": "string — what we are trying to achieve",
    "deadline": "ISO 8601 timestamp or null",
    "progress_pct": "number 0-100"
  },

  "agents": {
    "@agent-name": {
      "status": "ACTIVE | STANDBY | BLOCKED | OFFLINE",
      "current_task": "string — exactly what this agent is doing NOW",
      "files_locked": ["array of file paths this agent is modifying"],
      "last_update": "ISO 8601 timestamp",
      "blockers": ["array of blocker descriptions, or empty"]
    }
  },

  "file_locks": {
    "path/to/file": {
      "locked_by": "@agent-name",
      "locked_at": "ISO 8601 timestamp",
      "reason": "string — why this file is locked"
    }
  },

  "phases": {
    "phase_name": {
      "status": "PENDING | IN_PROGRESS | COMPLETED | BLOCKED",
      "agent": "@agent-name or 'unassigned'",
      "tasks": ["array of task descriptions"],
      "estimated_time": "string (e.g. '30 minutes')"
    }
  },

  "last_updated": "ISO 8601 timestamp",
  "next_action": "string — what should happen next"
}
```

A ready-to-use template is provided at `templates/agent_sync_state.json`.

### State File Rules

| Rule | Rationale | Enforcement |
|------|-----------|-------------|
| Every active repo MUST have `.agent_sync_state.json` at root | Agents need a standard location to check state | Agent startup check |
| Schema MUST match the standard above | Agents need predictable fields to read | Validation on read |
| `last_updated` MUST be current | Stale state leads to wrong decisions | Warn if > 24 hours old |
| File locks auto-expire after 30 minutes | Prevents abandoned locks from blocking work | Prune on read |
| Offline agents are pruned after 15 minutes | Prevents phantom agents in the registry | Prune on read |
| NEVER store secrets in state files | State files are committed to git | Secrets go in `.env` only |
| State files MUST be committed to git | Other agents and sessions need to read them | Part of the repo |

### Session Handoff via State File

When a session ends:
1. Update `.agent_sync_state.json` with final state
2. Set your agent status to `OFFLINE`
3. Update `last_updated` timestamp
4. Commit with message: `state: close session [id]`

When a new session starts:
1. Read `.agent_sync_state.json` — understand current state
2. Prune agents with `last_update` > 15 minutes ago
3. Register yourself as ACTIVE with `current_task`
4. Update `last_updated`
5. Begin work

---

## Skills Governance

### The Problem with Skill Duplication

Skills can be installed at multiple levels:
- User-level (applies to all projects)
- Project-level (applies to one repo)
- Tool-specific (applies to one tool)

When the same skill exists at multiple levels, agents may pick up an outdated version. When skills are copied between directories, they diverge.

### Priority Hierarchy

```
Priority 1 (highest): User-level skills     (e.g. ~/.config/opencode/skills/)
Priority 2:           Project-level skills   (e.g. [repo]/.agents/skills/)
Priority 3 (lowest):  Tool-specific skills   (e.g. [repo]/.opencode/skills/)
```

If a skill exists at a higher priority level, it wins. Lower-priority copies should be removed.

### Skills Rules

| Rule | Details |
|------|---------|
| **No duplicate skills** | If a skill exists at user-level, do NOT duplicate it at project-level or tool-level |
| **Every skill MUST have SKILL.md** | The `SKILL.md` file is the entry point. No exceptions. |
| **Skills MUST NOT contain secrets** | No API keys, tokens, or credentials in skill files |
| **New skills require a decision log entry** | Document the addition in the decision log |
| **Skill modifications require a date stamp** | Add `Last Updated: YYYY-MM-DD` to the SKILL.md header |

### Deduplication Procedure

Before creating or modifying a skill:

1. **Check all skill directories** for existing copies of the same skill
2. **If duplicate found at higher priority level:** remove the lower-priority copy
3. **If duplicate found at lower priority level:** remove it, keep the higher-priority version
4. **If no duplicate:** proceed with creation

```bash
# Example: check for duplicates across directories
ls ~/.config/opencode/skills/ | sort > /tmp/user_skills
ls .agents/skills/ 2>/dev/null | sort > /tmp/project_skills
ls .opencode/skills/ 2>/dev/null | sort > /tmp/tool_skills
comm -12 /tmp/user_skills /tmp/project_skills    # User vs Project duplicates
comm -12 /tmp/user_skills /tmp/tool_skills        # User vs Tool duplicates
comm -12 /tmp/project_skills /tmp/tool_skills     # Project vs Tool duplicates
```

---

## Registry Protocol

### Decision Log

An append-only log of significant technical and process decisions. This is critical for cross-session continuity — when a new agent or session starts, they need to know what was decided and why.

**Location:** `[repo]/docs/registry/decision-log.md` (per-repo, not centralized)

**Type:** Append-only. Never delete entries. Never edit past entries.

**When to log a decision:**
- Choosing a technology, framework, or service provider
- Changing AI model routing or fallback chains
- Modifying sovereign configuration files
- Adding or removing repositories from the ecosystem
- Changing deployment targets or environments
- Any breaking change to APIs, schemas, or interfaces
- Adding or deprecating skills

**Entry format:**

```markdown
## YYYY-MM-DD

- **[CATEGORY] Decision title**
  - Rationale: Why this decision was made
  - Alternatives: What else was considered
  - Reference: Link to commit, document, or discussion
  - Impact: What changes as a result
  - Owner: Who made the call
```

**Categories:**

| Category | Use For |
|----------|---------|
| `ARCH` | Architecture decisions (tech stack, patterns, service choices) |
| `INFRA` | Infrastructure changes (cloud, deployment, networking) |
| `MODEL` | AI model selection, routing, fallback chain changes |
| `SECURITY` | Security policies, auth changes, access control |
| `DEPLOY` | Deployment pipeline, environments, release strategy |
| `DATA` | Database schema, data model, migration decisions |
| `SKILL` | Skill additions, modifications, deprecations |
| `PROCESS` | Workflow, review process, team coordination changes |

### Session State Log

A record of work sessions for cross-session continuity. When a new session starts, the agent reads this to understand what happened previously.

**Location:** `[repo]/docs/registry/session-state.md` (per-repo, not centralized)

**Type:** Append-only.

**Entry format:**

```markdown
## YYYY-MM-DD

- **Session focus:** One-line description of what this session was about
- **Current phase:** Where we are in the broader plan
- **Artifacts referenced:** List of files/documents read or modified
- **Artifacts created:** List of new files created, with artifact IDs if applicable
- **Decisions made:** Brief summary (full details in decision-log.md)
- **Blockers:** Any blockers encountered
- **Handoff notes:** What the next session needs to know

Last updated: ISO 8601 timestamp
```

### Artifact Registry

A living index of documentation artifacts. Tracks what exists, where it lives, what depends on what, and whether it's up to date.

**Location:** `[repo]/docs/registry/artifact-registry.md` (per-repo)

**Naming convention:**

| Prefix | Category | Examples |
|--------|----------|----------|
| `GOV-XXX` | Governance & Protocol | AGENTS.md, compliance docs |
| `ARCH-XXX` | Architecture Decisions & Designs | System architecture, tech stack decisions |
| `EXT-XXX` | Extracted/Migrated Documents | Docs pulled from other sources |
| `FUT-XXX` | Future Architecture Plans | Roadmaps, phase plans |
| `DB-XXX` | Database Schemas & Data Models | Schema definitions, migration docs |
| `API-XXX` | API Specifications | REST, WebSocket, GraphQL specs |
| `AGENT-XXX` | Agent Specifications | Agent hierarchy, swarm configs |
| `INFRA-XXX` | Infrastructure Documentation | Cloud config, Terraform, CI/CD |
| `TEST-XXX` | Testing Specifications | Test plans, QA specs, test matrices |
| `DASH-XXX` | Dashboard & UI Specifications | UI specs, component libraries |
| `INTEG-XXX` | Integration Documentation | Third-party integrations, data flows |
| `SKILL-XXX` | Skill Documentation | Skill creation, skill audits |

**Registry entry format:**

| Field | Description |
|-------|-------------|
| Artifact ID | Unique ID following the naming convention |
| Name | Human-readable name |
| Path | File path relative to repo root |
| Version | Semantic version (major.minor.patch) |
| Dependencies | Other artifacts this one depends on |
| Dependents | Other artifacts that depend on this one |
| Owner | Who is responsible for maintaining it |
| Last Sync | When it was last updated |
| Status | Compliant / Partial / Non-Compliant / Deprecated |

---

## Agent Startup Protocol

Every agent MUST follow this sequence when activated in a repository:

```
STEP 1: VERIFY WORKING DIRECTORY
        Confirm you are in the correct repository.
        If wrong directory, STOP and navigate correctly.

STEP 2: READ AGENTS.MD
        Read the repo's AGENTS.md.
        If it's a pointer (< threshold lines, contains "POINTER FILE"):
            Follow it to the canonical AGENTS.md. Read the canonical.
        If it's NOT a pointer (full copy, > threshold lines):
            This is a GOVERNANCE VIOLATION.
            Flag it. Follow the canonical version instead.

STEP 3: READ STATE FILE
        Read .agent_sync_state.json if it exists.
        Check for active missions, file locks, blockers.
        Prune offline agents (last_update > 15 min ago).

STEP 4: READ SESSION CONTEXT
        Read docs/registry/session-state.md if it exists.
        Understand what the previous session accomplished.
        Read docs/registry/decision-log.md for recent decisions.

STEP 5: REGISTER YOURSELF
        Update .agent_sync_state.json:
        - Add yourself to the agents section with status ACTIVE
        - Set your current_task
        - Update last_updated timestamp

STEP 6: BEGIN WORK
        Only after steps 1-5 are complete.
```

---

## Compliance Violations

### Violation Severity Matrix

| Violation | Severity | Agent Response |
|-----------|----------|----------------|
| AGENTS.md is a full copy (> threshold lines) in a non-canonical repo | CRITICAL | Replace with pointer. Log violation. If git hook installed, commit is blocked. |
| AGENTS.md exists but has no "POINTER FILE" marker | CRITICAL | Replace with pointer. Log violation. |
| AGENTS.md doesn't reference the canonical location | CRITICAL | Replace with pointer. Log violation. |
| Agent is working in the wrong directory | CRITICAL | STOP immediately. Navigate to correct directory. Do not continue. |
| Sovereign file modified without owner approval | CRITICAL | Revert change. Escalate to owner. Do not continue. |
| State file missing from active repo | HIGH | Create from template. Log the creation. |
| State file doesn't match standard schema | HIGH | Migrate to standard schema. Preserve existing data. Log. |
| Skill duplicated across directories | MEDIUM | Remove lower-priority duplicate. Keep higher-priority version. |
| Decision not logged | MEDIUM | Add entry to decision log retroactively. |
| Session not properly handed off | LOW | Update session state at start of next session. |
| State file timestamp > 24 hours old | LOW | Update timestamp. Prune offline agents. |

### Escalation Protocol

```
Agent detects issue
     |
     v
Classify severity (see table above)
     |
     +-- LOW
     |   Log it in session state.
     |   Fix inline (update timestamp, add missing entry).
     |   Continue working.
     |
     +-- MEDIUM
     |   Log it in session state.
     |   Fix inline (remove duplicate, add log entry).
     |   Flag in session state for awareness.
     |   Continue working.
     |
     +-- HIGH
     |   Log it in session state AND decision log.
     |   Fix immediately (create state file, migrate schema).
     |   Verify the fix worked.
     |   Continue working.
     |
     +-- CRITICAL
         STOP ALL WORK.
         Log it in session state AND decision log.
         Escalate to owner/founder.
         Do NOT continue until the issue is resolved.
```

---

## Cross-Repo Documentation Policy

This is the single most important design decision: **governance is centralized, documentation is not.**

| What | Where It Lives | Centralized? | Why |
|------|---------------|-------------|-----|
| `AGENTS.md` (governance) | Canonical location (ONE copy) | YES | Agents need one set of rules |
| State file schema | Defined in this skill | YES | Agents need predictable state format |
| Skills standards | Defined in this skill | YES | Prevent duplication and conflicts |
| Architecture docs | Per-repo `docs/` | NO | Architecture belongs with the code it describes |
| Session logs | Per-repo `docs/registry/` | NO | Sessions are repo-specific work |
| Decision logs | Per-repo `docs/registry/` | NO | Decisions are made in context of specific repos |
| README.md | Per-repo root | NO | Each repo describes itself |
| Source code | Per-repo | NO | Obviously |
| Tests | Per-repo | NO | Tests belong with the code they test |

**Never consolidate documentation across repos.** The temptation is strong — "let's put all architecture docs in one place!" — but it breaks the locality principle. When you're working in repo-3, you need repo-3's docs right there, not in a separate repo you have to go find.

---

## Enforcement Tools

### Shell Aliases

```bash
enforce          # Audit mode — scan all repos, report compliant vs stale
enforce-fix      # Fix mode — replace all stale AGENTS.md with pointers
```

### Enforcement Script (`scripts/enforce.sh`)

The script:
1. Reads `SOVEREIGN_CANONICAL` to find the canonical file (falls back to `$HOME/governance/AGENTS.md`)
2. Verifies the canonical file exists
3. Scans all directories up to 2 levels deep from `SOVEREIGN_HOME`
4. Finds every `AGENTS.md`, excluding `node_modules/`, `.next/`, `.git/`
5. Classifies each as COMPLIANT (valid pointer) or STALE (full copy or broken pointer)
6. In `--fix` mode: generates a pointer for each stale file with auto-classified repo metadata
7. Reports compliance percentage

### Git Pre-Commit Hook (`scripts/pre-commit`)

Installed globally via `git config --global core.hooksPath`:
1. Fires on every `git commit` in any repo on the machine
2. Checks if `AGENTS.md` exists in the repo being committed to
3. Skips if the file IS the canonical (you're allowed to commit canonical changes)
4. Verifies the file is a valid pointer
5. If NOT valid: blocks the commit with a clear error message and fix instructions
6. Can be bypassed with `git commit --no-verify` (not recommended)

---

## New Repository Checklist

When creating ANY new repository in the ecosystem:

```
[ ] 1. Create the repository (git init, GitHub, etc.)
[ ] 2. Copy templates/AGENTS.md.template to AGENTS.md
       Fill in: repo name, purpose, governance level, status, canonical path
[ ] 3. Add README.md describing the repo's purpose
[ ] 4. Add .gitignore (exclude .env, node_modules, .next, dist, .DS_Store)
[ ] 5. Add .env.example if the repo uses environment variables (NO real values)
[ ] 6. Copy templates/agent_sync_state.json to .agent_sync_state.json
       Update session ID and timestamps
[ ] 7. Create docs/registry/ directory if this is a primary (non-archived) repo
       Add decision-log.md and session-state.md
[ ] 8. Run 'enforce' to verify compliance
[ ] 9. Initial commit and push
```

---

## Quick Reference Card

```
+-------------------------------------------------------------------+
|  SOVEREIGN GOVERNANCE — QUICK REFERENCE                            |
+-------------------------------------------------------------------+
|                                                                     |
|  CANONICAL FILE                                                    |
|    Location:  $SOVEREIGN_CANONICAL                                 |
|    Authority: One file to rule them all                            |
|    Edit:      Only edit the canonical. Never repo copies.          |
|                                                                     |
|  COMMANDS                                                          |
|    enforce        Audit all repos (report only)                    |
|    enforce-fix    Fix all stale AGENTS.md (replace with pointers)  |
|                                                                     |
|  POINTER DETECTION                                                 |
|    Valid pointer = < 50 lines + "POINTER FILE" + canonical ref     |
|    Anything else = STALE (violation)                               |
|                                                                     |
|  GOVERNANCE LEVELS                                                 |
|    SOVEREIGN:   Owner only        (core infra, configs)            |
|    STRATEGIC:   Owner + Lead      (architecture, plans)            |
|    TACTICAL:    Assigned Agent    (features, tools)                |
|    OPERATIONAL: Any Agent         (archived, experiments)          |
|                                                                     |
|  DOCUMENTATION POLICY                                              |
|    Governance:  Centralized (one canonical AGENTS.md)              |
|    Everything:  Per-repo (docs stay where the code is)             |
|                                                                     |
|  STATE FILES                                                       |
|    Schema:      .agent_sync_state.json (standard schema)           |
|    Secrets:     NEVER in state files. Use .env only.               |
|    Locks:       Auto-expire after 30 minutes                       |
|                                                                     |
|  SKILLS                                                            |
|    Priority:    User-level > Project-level > Tool-level            |
|    Duplicates:  Remove lower-priority copy                         |
|    Required:    Every skill must have SKILL.md                     |
|                                                                     |
|  AGENT STARTUP                                                     |
|    1. Verify directory                                             |
|    2. Read AGENTS.md (follow pointer to canonical)                 |
|    3. Read state file                                              |
|    4. Read session context                                         |
|    5. Register yourself                                            |
|    6. Begin work                                                   |
|                                                                     |
+-------------------------------------------------------------------+
```

---

*Sovereign Governance v1.0*
*"One source of truth. Everything else is a pointer."*
