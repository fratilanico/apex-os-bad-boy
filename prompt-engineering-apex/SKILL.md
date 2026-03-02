---
name: prompt-engineering-apex
description: "Use when writing prompts for Claude or any LLM, when agent outputs are inconsistent or low quality, when structuring system prompts for APEX OS agents, or when implementing CoT/ToT reasoning patterns. Triggers on: prompt design, system prompt, instruction engineering, output quality, JSON schema enforcement."
tier: FULL
tags: [prompting, llm, cot, tot, json, apex-os, agents]
source: HandsOnLLM Ch.6 + DeepLearning.AI Agent Skills
last-updated: 2026-02-27
---

# Prompt Engineering — APEX OS Standard

## Overview

Seven-component prompt anatomy from HandsOnLLM Ch.6. Every high-stakes agent prompt
in APEX OS uses this structure. Deviating = degraded output.

## The 7-Component Anatomy

```
┌─────────────────────────────────────────────────────────────────────────┐
│ Component    │ Purpose                          │ Required?              │
├─────────────────────────────────────────────────────────────────────────┤
│ 1. Role      │ Who the model is                 │ Always                 │
│ 2. Context   │ Background the model needs       │ Always                 │
│ 3. Task      │ Exactly what to do               │ Always                 │
│ 4. Format    │ Output structure (JSON, list...) │ Always                 │
│ 5. Examples  │ Few-shot demonstrations          │ For complex outputs    │
│ 6. Guardrails│ What NOT to do                   │ For production agents  │
│ 7. Reasoning │ CoT activator                    │ For non-trivial tasks  │
└─────────────────────────────────────────────────────────────────────────┘
```

## Template

```xml
<system>
  <!-- 1. ROLE -->
  You are {role} at APEX OS. You {core_competency}.

  <!-- 2. CONTEXT -->
  {background_facts_the_model_needs}

  <!-- 3. TASK -->
  Your task: {specific_action_verb} {object} given {input_description}.

  <!-- 6. GUARDRAILS -->
  Never: {prohibited_actions}
  Always: {required_behaviours}
</system>

<user>
  <!-- 5. EXAMPLES (few-shot) -->
  Example:
  Input: {example_input}
  Output: {example_output}

  <!-- 3. TASK (instance) -->
  Now do the same for:
  {actual_input}

  <!-- 7. REASONING ACTIVATOR -->
  Think step by step before answering.
</user>
```

## CoT Patterns (Chain-of-Thought)

### Zero-shot CoT — append to any prompt:
```
"Think step by step before answering."
"Let's work through this carefully."
"Reason through this before giving your final answer."
```

### Structured CoT — for agent tasks:
```
Before answering:
Thought: [What is the actual question?]
Approach: [What method applies?]
Step 1: ...
Step 2: ...
Conclusion: [Final answer with zero hedging]
```

## ToT Pattern (Tree-of-Thought) — for irreversible decisions

```
"Imagine 3 experts answering this question. Each writes one step of
thinking and shares it with the group. Any expert who realizes they
are wrong drops out. The group continues until one answer remains."
```

Use for: architecture decisions, security design, cost trade-offs.

## Constrained JSON Output

Force structured output — never let the model free-form when you need JSON:

```python
# OpenAI / Azure OpenAI
response = client.chat.completions.create(
    model="gpt-5.2-chat",
    messages=[{"role": "user", "content": prompt}],
    response_format={
        "type": "json_schema",
        "json_schema": {
            "name": "lead_score",
            "schema": {
                "type": "object",
                "properties": {
                    "score": {"type": "integer", "minimum": 0, "maximum": 100},
                    "reason": {"type": "string"},
                    "tier": {"type": "string", "enum": ["hot", "warm", "cold"]}
                },
                "required": ["score", "reason", "tier"],
                "additionalProperties": False
            }
        }
    }
)
```

## APEX OS Prompt Anti-Patterns

```
┌──────────────────────────────────┬────────────────────────────────────┐
│ ❌ Anti-Pattern                   │ ✅ Fix                              │
├──────────────────────────────────┼────────────────────────────────────┤
│ Vague role: "You are an AI"      │ "You are APEX OS lead scorer"      │
│ No format spec → free text       │ JSON schema with required fields   │
│ No guardrails → hallucination    │ Explicit NEVER / ALWAYS rules      │
│ No CoT → shallow reasoning       │ Append "Think step by step"        │
│ Wall of text prompt               │ XML-tagged sections per component  │
└──────────────────────────────────┴────────────────────────────────────┘
```

## Common Mistakes

- Skipping the Format component — model outputs prose instead of parseable data
- No guardrails on production agents — model invents data when uncertain
- Using ToT for simple tasks — overhead not worth it; CoT is enough
- Forgetting few-shot examples for complex JSON — model gets schema wrong
