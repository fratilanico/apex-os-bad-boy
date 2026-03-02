---
name: basic-qa-smoke
description: Smoke test checklist and lightweight validation. Use after small changes or before demo.
tier: BASE
value_tier: silverware
tags: [tier-base, silverware, qa]
entitlements:
  product_tiers: [base, upper, full]
  agent_access: [qa-smoke, builder-lite]
---

# Basic QA Smoke

## When to use
- After small UI or backend changes
- Before a demo or preview share

## Smoke checklist
- App loads without console errors
- Primary navigation works
- Core user flow completes
- Error states render correctly
- Mobile layout sanity check

## Output format
- Test scope
- Results (pass/fail)
- Issues found with severity
