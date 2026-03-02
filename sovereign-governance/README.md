# Sovereign Governance

> "One source of truth. Everything else is a pointer."

Sovereign Governance is a skill and enforcement toolkit for multi-repo AI agent ecosystems. It solves the fundamental problem of **governance drift** — where agent instructions, configuration files, and operational skills duplicate across repositories, silently diverge, and cause agents to follow conflicting rules.

---

## Table of Contents

- [The Problem](#the-problem)
- [The Solution](#the-solution)
- [Architecture](#architecture)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [How It Works](#how-it-works)
- [Concepts](#concepts)
- [Enforcement](#enforcement)
- [Templates](#templates)
- [Customization](#customization)
- [File Reference](#file-reference)
- [FAQ](#faq)

---

## The Problem

If you work with AI agents (Claude, GPT, Cursor, OpenCode, Gemini, Codex, or any SKILL.md-compatible tool) across multiple repositories, you've hit this:

1. **Governance drift.** You write an `AGENTS.md` with rules for how agents should behave. You copy it into each repo. Over time, each copy gets edited independently. Now you have 5 versions of "the truth" and agents in different repos follow different rules.

2. **State file chaos.** Each repo invents its own format for tracking agent state — `.agent_sync_state.json`, `.neural-sync-state.json`, `.agent_live_connection.json`. No shared schema. No shared protocol. Agents can't hand off context between repos.

3. **Skill duplication.** Skills get copied into multiple directories. The same skill exists at user-level, project-level, and tool-specific directories with different versions. Agents pick up whichever copy they find first — which may be outdated.

4. **No enforcement.** There's no mechanism to detect drift, block stale commits, or audit compliance. Problems are discovered when an agent does the wrong thing in production.

### What This Looks Like at Scale

```
repo-1/AGENTS.md       5,400 lines    Last updated: Jan 15
repo-2/AGENTS.md       5,537 lines    Last updated: Jan 20 (different rules)
repo-3/AGENTS.md       7,048 lines    Last updated: Feb 1 (extra sections)
repo-4/AGENTS.md       5,351 lines    Last updated: Jan 10 (stale)
repo-5/AGENTS.md         110 lines    Last updated: Feb 5 (stripped down)
...
repo-20/AGENTS.md      5,496 lines    Last updated: Dec 28 (ancient)
```

20 repos. 20 different versions of agent governance. Agents in repo-3 follow rules that don't exist in repo-1. Agents in repo-20 follow rules from last year. Nobody knows which version is correct.

---

## The Solution

One canonical governance file. Every repo gets a 36-line pointer that says "go read the canonical." Automated enforcement catches drift before it spreads.

```
canonical-location/AGENTS.md        <- ONE file. The source of truth.
        |
        |-- repo-1/AGENTS.md        <- 36-line pointer
        |-- repo-2/AGENTS.md        <- 36-line pointer
        |-- repo-3/AGENTS.md        <- 36-line pointer
        |-- repo-N/AGENTS.md        <- 36-line pointer
        '-- [new repo]/AGENTS.md    <- 36-line pointer (auto-generated)
```

### What Changes

| Before | After |
|--------|-------|
| 20 copies of AGENTS.md, all different | 1 canonical + 20 pointers |
| No way to detect drift | Audit script shows violations in seconds |
| Stale copies committed silently | Git hook blocks commits with stale AGENTS.md |
| New repos forget governance | Template auto-generates pointer on repo creation |
| State files have no shared schema | Standard schema with validation rules |
| Skills duplicated everywhere | Deduplication rules with priority hierarchy |

---

## Architecture

### The Pointer Model

The pointer model separates **governance** (centralized) from **documentation** (per-repo):

```
CENTRALIZED (one copy, pointers everywhere):
  - AGENTS.md governance rules
  - State file schema definition
  - Skills standards and deduplication rules

PER-REPO (stays where the work happens, NOT consolidated):
  - Architecture docs
  - Session logs
  - Decision logs
  - README.md
  - Source code
  - Tests
```

This distinction is critical. Governance must be unified — agents need one set of rules. But documentation must stay local — architecture docs belong with the code they describe.

### What a Pointer Looks Like

Every non-canonical repo's `AGENTS.md` is a small file (~36 lines) that contains:

1. A clear "POINTER FILE" header so agents know not to treat it as governance
2. The path to the canonical AGENTS.md
3. Repo-specific metadata (name, purpose, governance level, status)
4. Instructions: "Read the canonical. Follow it. If conflicts arise, canonical wins."

Agents read the pointer, follow it to the canonical, and execute from there. No ambiguity. No drift.

### Governance Levels

Every repo is classified by how sensitive its artifacts are:

| Level | Authority | Who Can Modify | Typical Repos |
|-------|-----------|----------------|---------------|
| **SOVEREIGN** | Absolute | Founder/Owner only | Core infrastructure, primary API |
| **STRATEGIC** | High | Owner + Lead Agent | Architecture repos, planning repos |
| **TACTICAL** | Medium | Assigned Agent | Feature repos, dashboards, tools |
| **OPERATIONAL** | Standard | Any Agent | Archived repos, experiments, POCs |

The enforcement script auto-classifies known repos and assigns appropriate levels when generating pointers.

---

## Installation

### Via skills.sh (Recommended)

Works with Claude Code, Cursor, Cline, Codex, Gemini CLI, OpenCode, Antigravity, and any SKILL.md-compatible agent:

```bash
npx skills add fratilanico/sovereign-governance
```

To install globally (user-level, applies to all projects):

```bash
npx skills add fratilanico/sovereign-governance --global
```

### Via Git Clone

```bash
# Clone to your skills directory
git clone https://github.com/fratilanico/sovereign-governance.git ~/.agents/skills/sovereign-governance
```

### Manual

Download the files and place them in your agent's skill directory:
- Claude Code: `~/.claude/skills/sovereign-governance/`
- Cursor: `~/.cursor/skills/sovereign-governance/`
- OpenCode: `~/.config/opencode/skills/sovereign-governance/`
- Generic: `~/.agents/skills/sovereign-governance/`

---

## Configuration

After installation, configure the skill for your environment.

### Step 1: Choose Your Canonical Location

Decide where the ONE canonical `AGENTS.md` will live. This should be **above** all your repos — not inside any single repo.

Good choices:
- `~/governance/AGENTS.md` — dedicated governance directory
- `~/archive/AGENTS.md` — if you have a personal knowledge archive
- `~/AGENTS.md` — simplest option, at home directory root

Bad choices:
- `~/my-main-repo/AGENTS.md` — this makes one repo "special" and creates circular dependencies
- Inside any repo that other repos depend on — fragile coupling

### Step 2: Set Environment Variables

Add to your `~/.zshrc`, `~/.bashrc`, or `~/.profile`:

```bash
# Sovereign Governance Configuration
export SOVEREIGN_CANONICAL="$HOME/governance/AGENTS.md"  # Path to your canonical AGENTS.md
export SOVEREIGN_HOME="$HOME"                             # Parent directory of all repos
export SOVEREIGN_MAX_LINES=50                             # Pointer threshold (files > this = stale)
```

### Step 3: Move Your Canonical AGENTS.md

If you already have an `AGENTS.md` in a repo, move it to the canonical location:

```bash
mkdir -p ~/governance
mv ~/my-main-repo/AGENTS.md ~/governance/AGENTS.md
```

### Step 4: Install the Enforcement Script

```bash
cp ~/.agents/skills/sovereign-governance/scripts/enforce.sh ~/governance/enforce.sh
chmod +x ~/governance/enforce.sh
```

### Step 5: Add Shell Aliases

```bash
echo "" >> ~/.zshrc
echo "# Sovereign Governance" >> ~/.zshrc
echo "alias enforce='\$SOVEREIGN_CANONICAL/../enforce.sh'" >> ~/.zshrc
echo "alias enforce-fix='\$SOVEREIGN_CANONICAL/../enforce.sh --fix'" >> ~/.zshrc
source ~/.zshrc
```

### Step 6: Install the Git Hook

This makes enforcement automatic — every `git commit` in any repo checks AGENTS.md compliance:

```bash
mkdir -p ~/.config/git/hooks
cp ~/.agents/skills/sovereign-governance/scripts/pre-commit ~/.config/git/hooks/pre-commit
chmod +x ~/.config/git/hooks/pre-commit
git config --global core.hooksPath ~/.config/git/hooks
```

### Step 7: Run Initial Enforcement

```bash
# See the current state (audit mode)
enforce

# Fix all stale copies across all repos
enforce-fix
```

---

## Usage

### Daily Workflow

For most users, enforcement is automatic via the git hook. You only interact with the skill manually when:

1. **Creating a new repo** — copy `templates/AGENTS.md.template`, fill in the fields
2. **Running an audit** — type `enforce` in any terminal
3. **Fixing violations** — type `enforce-fix` to replace all stale copies
4. **Editing governance** — edit the canonical file directly, never repo copies

### For AI Agents

When an agent reads a repo's `AGENTS.md`, it should:

1. Check if the file is a pointer (< 50 lines, contains "POINTER FILE")
2. If pointer: follow it to the canonical location. Read the canonical. Follow it.
3. If NOT a pointer (> 50 lines, no "POINTER FILE" header): this is a governance violation. The agent should flag it, follow the canonical version instead, and note the violation.

### Commands

| Command | What It Does |
|---------|--------------|
| `enforce` | Scans all repos, reports compliant vs stale AGENTS.md files |
| `enforce-fix` | Scans all repos, replaces stale copies with properly classified pointers |
| `git commit` | Automatically checks AGENTS.md in the current repo (via pre-commit hook) |

---

## How It Works

### The Enforcement Script (`scripts/enforce.sh`)

The script performs these steps:

1. **Verifies the canonical file exists** at the configured path. If not, exits with an error.

2. **Scans all directories** up to 2 levels deep from the configured home directory. Finds every `AGENTS.md` file, excluding `node_modules/`, `.next/`, and `.git/`.

3. **Classifies each file** as COMPLIANT or STALE:
   - **COMPLIANT:** File is < 50 lines, contains "POINTER FILE" in the content, and references the canonical location
   - **STALE:** Anything else — a full copy, an old version, a modified version, or a file that doesn't reference the canonical

4. **In audit mode** (`enforce`): Reports findings. No modifications.

5. **In fix mode** (`enforce-fix`): Replaces every stale file with a properly generated pointer. The pointer includes the repo name, purpose, governance level, and status — auto-classified from a built-in registry of known repo types.

6. **Reports compliance** as a percentage with counts of compliant and stale files.

### The Git Hook (`scripts/pre-commit`)

The pre-commit hook runs on every `git commit` in any repo (installed globally via `core.hooksPath`):

1. Finds the repo root via `git rev-parse --show-toplevel`
2. Checks if `AGENTS.md` exists in that repo
3. Skips if the file IS the canonical (you're allowed to commit changes to the canonical)
4. Checks if the file is a valid pointer (< 50 lines, contains "POINTER FILE", references canonical)
5. If NOT a valid pointer: **blocks the commit** with a clear error message and instructions to fix

The hook can be bypassed with `git commit --no-verify`, but this is not recommended.

### Detection Logic

A file is considered a valid pointer if ALL three conditions are met:

```
1. Line count < 50
2. File contains the string "POINTER FILE"
3. File references the canonical location
```

This is deliberately simple. No regex parsing, no YAML frontmatter, no complex validation. If the file is short and says it's a pointer to the right place, it's compliant.

---

## Concepts

### Artifact Classification

Every file in the ecosystem is classified by sensitivity:

| Classification | Authority | Who Can Modify | Examples |
|---------------|-----------|----------------|----------|
| **SOVEREIGN** | Absolute — Owner only | The canonical `AGENTS.md`, root config files (`tsconfig.json`, `vercel.json`), environment templates (`.env.example`) | Only the founder/owner touches these |
| **STRATEGIC** | High — Owner + Lead | Architecture docs, implementation plans, artifact registries, deployment configs | Reviewed changes only |
| **TACTICAL** | Medium — Assigned Agent | Component specs, API designs, skill SKILL.md files, feature docs | Standard review process |
| **OPERATIONAL** | Standard — Any Agent | State files (`.agent_sync_state.json`), session logs, task boards, status reports | Updated freely during work |

### State File Standard

The skill defines a standard schema for `.agent_sync_state.json` — the file agents use to coordinate within a repo. Key fields:

| Field | Purpose |
|-------|---------|
| `session.id` | Unique session identifier |
| `session.mode` | Current operating mode (NORMAL, EMERGENCY, SAFE_MODE) |
| `orchestrator` | Which agent is coordinating, their status, last heartbeat |
| `current_mission` | What the system is trying to achieve, priority, deadline, progress |
| `agents` | Registry of active agents with current tasks, locked files, blockers |
| `file_locks` | Which files are being modified by which agent (prevents conflicts) |
| `phases` | Execution phases with status and assignments |

A ready-to-use template is included at `templates/agent_sync_state.json`.

**State file rules:**
- Every active repo MUST have `.agent_sync_state.json` at root
- Updates MUST include a `last_updated` timestamp
- File locks auto-expire after 30 minutes
- Offline agents are pruned after 15 minutes
- Secrets NEVER go in state files — secrets belong in `.env` only

### Skills Governance

When you have skills installed in multiple directories, conflicts arise. The skill defines a priority hierarchy:

```
Priority 1 (highest): ~/.config/opencode/skills/     (user-level)
Priority 2:           [repo]/.agents/skills/          (project-level)
Priority 3 (lowest):  [repo]/.opencode/skills/        (tool-specific)
```

**Rules:**
- If a skill exists at a higher priority level, do NOT duplicate it at a lower level
- Every skill MUST have a `SKILL.md` file — no exceptions
- Skills MUST NOT contain secrets (API keys, tokens, credentials)
- When adding a new skill, check all directories for duplicates first

### Decision Log

An append-only log of significant decisions. Never delete entries. Never edit past entries.

**When to log:**
- Choosing a technology, framework, or service
- Changing AI model routing or fallback chains
- Modifying sovereign configuration files
- Adding or removing repos from the ecosystem
- Changing deployment targets or environments
- Any breaking change to APIs, schemas, or interfaces

**Format:**
```markdown
## YYYY-MM-DD

- **[CATEGORY] Decision title**
  - Rationale: Why this decision was made
  - Alternatives: What was evaluated
  - Reference: Link to commit, doc, or discussion
  - Impact: What changes as a result
  - Owner: Who made the call
```

Categories: `ARCH` | `INFRA` | `MODEL` | `SECURITY` | `DEPLOY` | `DATA` | `SKILL` | `PROCESS`

### Session State

A log of work sessions for cross-session continuity. When an agent starts a new session, it reads this to understand where the previous session left off.

**Format:**
```markdown
## YYYY-MM-DD

- **Session focus:** One-line description
- **Current phase:** Where in the broader plan
- **Artifacts referenced:** Files read or modified
- **Artifacts created:** New files with IDs
- **Decisions made:** Summary (details in decision-log)
- **Blockers:** Any blockers encountered
- **Notes:** Free-form context
```

### Artifact Registry

A living index of documentation artifacts with dependency tracking, compliance scores, and ownership.

**Naming convention:**

| Prefix | Category |
|--------|----------|
| `GOV-XXX` | Governance & Protocol |
| `ARCH-XXX` | Architecture Decisions & Designs |
| `EXT-XXX` | Extracted/Migrated Architecture Docs |
| `FUT-XXX` | Future Architecture Plans |
| `DB-XXX` | Database Schemas & Data Models |
| `API-XXX` | API Specifications |
| `AGENT-XXX` | Agent Specifications |
| `INFRA-XXX` | Infrastructure Documentation |
| `TEST-XXX` | Testing Specifications |
| `DASH-XXX` | Dashboard & UI Specifications |
| `INTEG-XXX` | Integration Documentation |
| `SKILL-XXX` | Skill Documentation |

---

## Enforcement

### Three Layers of Enforcement

| Layer | When | How | Bypass |
|-------|------|-----|--------|
| **Shell alias** (`enforce`) | Manual — run anytime | Scans all repos, reports compliance | N/A (informational) |
| **Shell alias** (`enforce-fix`) | Manual — when violations found | Replaces all stale copies with pointers | N/A (always fixes) |
| **Git hook** (pre-commit) | Automatic — every commit | Blocks commit if AGENTS.md is stale | `git commit --no-verify` |

### Compliance Violations

| Violation | Severity | Automated Response |
|-----------|----------|-------------------|
| AGENTS.md > 50 lines in non-canonical location | CRITICAL | Git hook blocks commit. `enforce-fix` replaces with pointer. |
| AGENTS.md missing "POINTER FILE" header | CRITICAL | Same as above. |
| AGENTS.md not referencing canonical location | CRITICAL | Same as above. |
| State file missing from active repo | HIGH | Agent should create from template. |
| State file doesn't match schema | HIGH | Agent should migrate to standard schema. |
| Skill duplicated across directories | MEDIUM | Remove lower-priority duplicate. |
| Decision not logged | MEDIUM | Add entry to decision log retroactively. |
| Session not handed off properly | LOW | Update session state on next session start. |
| State file timestamp > 24 hours old | LOW | Update timestamp and prune offline agents. |

### Escalation Path

```
Agent detects issue
     |
     v
Classify severity
     |
     +-- LOW:      Log it. Fix inline. Continue working.
     +-- MEDIUM:   Log it. Fix inline. Flag in session state.
     +-- HIGH:     Log it. Fix immediately. Flag in decision log.
     +-- CRITICAL: STOP ALL WORK. Log. Escalate to owner. Do not continue.
```

---

## Templates

### `templates/AGENTS.md.template`

Copy this into any new repo as `AGENTS.md`. Replace the placeholder values:

- `CANONICAL_PATH` — absolute path to your canonical AGENTS.md
- `CANONICAL_LOCATION` — human-readable name for the canonical location
- `REPO_NAME` — repository name
- `DESCRIPTION` — what the repo does
- `GOVERNANCE_LEVEL` — SOVEREIGN / STRATEGIC / TACTICAL / OPERATIONAL
- `STATUS` — ACTIVE / REFERENCE / ARCHIVED
- `AUTHORITY` — name of the governance owner

### `templates/agent_sync_state.json`

A ready-to-use `.agent_sync_state.json` with all required fields pre-populated with sensible defaults. Copy to repo root and update values as work begins.

---

## Customization

### Adapting for Your Environment

The skill is designed around these configurable values:

| Variable | Default | Description |
|----------|---------|-------------|
| `SOVEREIGN_CANONICAL` | Not set (must configure) | Absolute path to your canonical AGENTS.md |
| `SOVEREIGN_HOME` | `$HOME` | Parent directory to scan for repos |
| `SOVEREIGN_MAX_LINES` | `50` | Max lines for a valid pointer file |

### Adapting the Enforcement Script

The `scripts/enforce.sh` file contains a `get_repo_info()` function with a `case` statement that classifies known repos. To add your own repos:

1. Open `scripts/enforce.sh`
2. Find the `case "$repo_name" in` block
3. Add entries for your repos with purpose, governance level, and status
4. Unrecognized repos default to TACTICAL / ACTIVE

### Adapting for Different Canonical Locations

The templates reference a canonical path. Before distributing pointers:

1. Update `SOVEREIGN_CANONICAL` in your shell config
2. Update the path in `scripts/enforce.sh` (line 14: `CANONICAL=`)
3. Update the path in `scripts/pre-commit` (line 7: `CANONICAL=`)
4. Update `templates/AGENTS.md.template` with your canonical path

### Using Without AGENTS.md

The pointer model works for any governance file, not just `AGENTS.md`. If your ecosystem uses a different filename (e.g., `CLAUDE.md`, `RULES.md`, `.cursorrules`), modify the enforcement script to scan for that filename instead.

---

## File Reference

```
sovereign-governance/
|
|-- SKILL.md                          Full governance protocol for AI agents.
|                                     This is what agents read. Contains all
|                                     rules, schemas, templates, and procedures
|                                     an agent needs to enforce governance.
|
|-- README.md                         This file. Human documentation.
|
|-- AGENTS.md                         Pointer file (eating our own dogfood).
|                                     Demonstrates the pointer format.
|
|-- scripts/
|   |-- enforce.sh                    The enforcement script. Scans all repos,
|   |                                 classifies AGENTS.md files as compliant
|   |                                 or stale, optionally replaces stale copies
|   |                                 with properly generated pointers.
|   |
|   '-- pre-commit                    Git pre-commit hook. Blocks commits in
|                                     any repo where AGENTS.md is stale.
|                                     Installed globally via core.hooksPath.
|
'-- templates/
    |-- AGENTS.md.template            Pointer template for new repos. Copy,
    |                                 fill in fields, done.
    |
    '-- agent_sync_state.json         State file schema template. Copy to
                                      repo root as .agent_sync_state.json.
```

---

## FAQ

### Why not use symlinks instead of pointer files?

Symlinks break across machines, CI environments, and when repos are cloned independently. Pointer files are plain text that any agent can read and follow. They also carry repo-specific metadata (purpose, governance level) that a symlink can't.

### Why not use a monorepo?

A monorepo solves the duplication problem but creates new ones: permission boundaries, CI complexity, repo size. The pointer model gives you single-source governance without requiring a single repo.

### Can I use this with any AI agent?

Yes. The skill uses the SKILL.md format which is supported by Claude Code, Cursor, OpenCode, Codex, Gemini CLI, Cline, and Antigravity. The enforcement scripts work in any bash environment.

### What if an agent doesn't support skills?

The enforcement script and git hook work independently of any agent. Even without skill support, the git hook prevents stale AGENTS.md from being committed, and the `enforce` command shows violations.

### Does this work on Linux?

Yes. The enforcement script uses bash 3.2+ compatible syntax (no associative arrays, no bash 4+ features). It works on macOS and Linux.

### Does this work in CI/CD?

The pre-commit hook runs in any environment with bash and git. You can also add `enforce` as a CI step to audit compliance on pull requests.

### What if two agents modify the canonical AGENTS.md simultaneously?

The canonical file is classified as SOVEREIGN — only the founder/owner should modify it. If you need collaborative editing, use standard git branching and PR review on the canonical file.

### How do I add a new repo to the ecosystem?

1. Create the repo
2. Copy `templates/AGENTS.md.template` to `AGENTS.md` in the repo root
3. Fill in the repo-specific fields
4. Run `enforce` to verify compliance
5. Commit and push

### How do I remove a repo from the ecosystem?

Delete the repo or archive it. The enforcement script will stop finding it on the next scan. No cleanup needed in the canonical file.

---

## Contributing

Issues and pull requests welcome at [github.com/fratilanico/sovereign-governance](https://github.com/fratilanico/sovereign-governance).

---

## License

MIT

---

*Sovereign Governance v1.0*
*"One source of truth. Everything else is a pointer."*
