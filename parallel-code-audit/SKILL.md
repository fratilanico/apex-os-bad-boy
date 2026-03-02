---
name: parallel-code-audit
description: Use when conducting a comprehensive code review or security audit of a codebase — dispatches parallel review agents per file/module, triages findings by severity, then dispatches parallel fix agents.
tier: advanced
triggers:
  - code audit
  - security review
  - bug hunt across multiple files
  - comprehensive code review
  - harden codebase
---

# Parallel Code Audit

## Overview

Systematic codebase audit using parallel subagents for review, severity triage, and parallel fix dispatch. Scales linearly — 4 agents reviewing 750 lines each finishes in the time of one reviewing 750.

## Core Pattern

### Phase 1: Partition and Review

Split codebase into independent chunks (by file, module, or functional area). Dispatch one subagent per chunk with identical review criteria.

```
Review prompt template:
"Review {file_path} for: security vulnerabilities, error handling gaps,
resource leaks, race conditions, input validation failures, and logic errors.
For each finding, output:
  - Location (file:line)
  - Severity: P0 (crash/security), P1 (data loss/corruption), P2 (degraded behavior), P3 (code quality)
  - Description (1 sentence)
  - Fix (1 sentence)"
```

**Partition heuristics:**
- ~500-1000 lines per agent (sweet spot for thoroughness)
- Keep related files together (e.g., a module + its helpers)
- Never split a single function across agents

### Phase 2: Triage and Deduplicate

Merge all agent findings into a single list. Deduplicate (agents reviewing adjacent files may flag the same root cause). Sort by severity.

```
Triage output format:
P0 (5 findings) — Fix immediately
P1 (12 findings) — Fix before merge
P2 (30 findings) — Fix in follow-up
P3 (73 findings) — Track as tech debt
```

### Phase 3: Parallel Fix Dispatch

Group P0/P1 fixes by file. Dispatch one fix agent per file (or logical group). Each agent receives:
- The specific findings to fix
- The file content
- Constraints: "Do not change public API signatures. Add tests if touching control flow."

```
Fix prompt template:
"Fix these {n} issues in {file_path}:
{numbered_findings}
Rules:
- Preserve existing behavior for non-buggy paths
- Add input validation, not just error handling
- If a fix requires changes in another file, document it but do NOT edit that file"
```

### Phase 4: Verify

Run linter, type checker, and tests after all fixes land. Review diff for unintended changes.

## Rules

- Split codebase into non-overlapping chunks of 500-1000 lines per agent
- Never split a single function across agents
- Severity definitions must be provided in prompt (P0-P3)
- Deduplicate findings across agents before dispatching fixes
- Separate P0/P1 fixes from P2/P3 — different PRs
- Constrain fix agents: "Fix only the listed issues, preserve existing behavior"

## Checklist

- [ ] Partition codebase into independent chunks by file or module
- [ ] Dispatch parallel review agents with identical severity criteria
- [ ] Merge and deduplicate findings across all agents
- [ ] Sort by severity: P0 first, P3 last
- [ ] Dispatch parallel fix agents — one per file, non-overlapping
- [ ] Run linter + type checker + tests after all fixes land
- [ ] Review combined diff for unintended behavioral changes

## Examples

### Prompt for Review Agent
```
Review {file_path} ({line_count} lines) for: security vulnerabilities, error handling
gaps, resource leaks, race conditions, input validation failures, and logic errors.
Output severity P0-P3, location (file:line), description, and fix for each finding.
```

### Prompt for Fix Agent
```
Fix these {n} issues in {file_path}: {numbered_findings}
Rules: Preserve existing behavior. Add input validation. Do NOT edit other files.
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Agents reviewing overlapping files produce conflicting fixes | Assign non-overlapping file sets per agent |
| Fixing P3 issues in the same PR as P0 | Separate by severity — P0/P1 in one PR, P2/P3 in follow-up |
| Agents inventing severity levels | Provide explicit P0-P3 definitions in prompt |
| Not deduplicating across agents | One finding may appear in 3 agents' output if it's a shared pattern |
| Fix agents changing too much | Constrain scope: "Fix only the listed issues" |

## When NOT to Use

- Single-file reviews (just review it directly)
- When the codebase has no tests (fix that first — blind fixes are dangerous)
- Trivial linting issues (use an autoformatter instead)
