---
name: react-agent-loop
description: "Use when building AI agents that need to reason and act in loops, when an agent needs to use tools iteratively, when implementing memory across agent turns, or when debugging an agent that gets stuck or loops infinitely. Triggers on: ReAct, agent loop, tool use, memory, LangChain, agent stuck."
tier: FULL
tags: [react, agents, tools, memory, langchain, loops, apex-os]
source: HandsOnLLM Ch.7
last-updated: 2026-02-27
---

# ReAct Agent Loop — APEX OS Standard

## Overview

From HandsOnLLM Ch.7. ReAct = Reason + Act. The fundamental pattern for
tool-using agents. All APEX OS agents that use external tools follow this.

## The ReAct Pattern

```
┌─────────────────────────────────────────────────────────────────────────┐
│  ReAct Loop                                                             │
│                                                                         │
│  Input → [THOUGHT] → [ACTION] → [OBSERVATION] → [THOUGHT] → ...        │
│                                                          ↓              │
│                                                    [FINAL ANSWER]       │
└─────────────────────────────────────────────────────────────────────────┘

Thought:  "I need to find the company email for this lead"
Action:   search_web(query="Acme Corp contact email")
Observation: "Found: contact@acme.com on their website"
Thought:  "I have the email. I can now score this lead."
Action:   score_lead(email="contact@acme.com", company="Acme Corp")
Observation: {"score": 78, "tier": "warm"}
Final Answer: Lead scored 78/100, warm tier.
```

## Minimal ReAct Implementation

```python
def react_agent(task: str, tools: dict, max_iterations: int = 10) -> str:
    messages = [
        {"role": "system", "content": REACT_SYSTEM_PROMPT},
        {"role": "user", "content": task}
    ]

    for iteration in range(max_iterations):
        response = llm.complete(messages)

        # Parse thought + action
        if "Final Answer:" in response:
            return response.split("Final Answer:")[-1].strip()

        action_name, action_input = parse_action(response)

        # Execute tool
        if action_name not in tools:
            observation = f"Error: Tool '{action_name}' not found."
        else:
            observation = tools[action_name](action_input)

        # Feed observation back
        messages.append({"role": "assistant", "content": response})
        messages.append({"role": "user", "content": f"Observation: {observation}"})

    return "Max iterations reached. Last state: " + response
```

## Memory Strategies

```
┌──────────────────────────────────────────────────────────────────────┐
│ Strategy      │ How it works          │ Best for                     │
├──────────────────────────────────────────────────────────────────────┤
│ Buffer        │ Keep all messages     │ Short conversations (<20 msgs)│
│ Window        │ Keep last N messages  │ Medium sessions, rolling ctx  │
│ Summary       │ Summarise old msgs    │ Long sessions, preserve meaning│
│ Vector Store  │ Embed + retrieve      │ Long-term cross-session memory │
└──────────────────────────────────────────────────────────────────────┘
```

### Window Memory (APEX OS default for agents):
```python
class WindowMemory:
    def __init__(self, window_size: int = 10):
        self.messages = []
        self.window_size = window_size

    def add(self, role: str, content: str):
        self.messages.append({"role": role, "content": content})
        # Keep system prompt + last N turns
        if len(self.messages) > self.window_size + 1:
            self.messages = [self.messages[0]] + self.messages[-(self.window_size):]

    def get(self) -> list:
        return self.messages
```

### Summary Memory (for long lead-gen pipeline sessions):
```python
def summarise_old_messages(messages: list, keep_last: int = 6) -> list:
    if len(messages) <= keep_last + 1:
        return messages

    to_summarise = messages[1:-keep_last]  # skip system prompt
    summary = llm.complete(
        f"Summarise these conversation turns in 3 bullet points:\n"
        + "\n".join(f"{m['role']}: {m['content']}" for m in to_summarise)
    )
    return [messages[0],
            {"role": "system", "content": f"[Previous context summary]\n{summary}"},
            *messages[-keep_last:]]
```

## Tool Description Rules (CRITICAL)

Tools fire based on their description. Write for semantic matching:

```python
tools = [
    {
        "name": "search_company_info",
        # ❌ Bad: "Searches for company information"
        # ✅ Good: describes WHEN to use it
        "description": "Use to find company website, contact email, industry, "
                       "headcount, and LinkedIn URL for a given company name. "
                       "Do NOT use for person-level searches.",
        "parameters": {
            "type": "object",
            "properties": {
                "company_name": {"type": "string", "description": "Legal company name"}
            },
            "required": ["company_name"]
        }
    }
]
```

## Infinite Loop Prevention

```python
# Detect repeated actions
action_history = []

def check_loop(action_name: str, action_input: str) -> bool:
    key = f"{action_name}:{action_input}"
    if action_history.count(key) >= 2:
        return True  # Loop detected
    action_history.append(key)
    return False

# In loop:
if check_loop(action_name, action_input):
    return "Agent stuck in loop. Last action: " + action_name
```

## Common Mistakes

- No max_iterations guard — agent loops forever on LLM error
- Tool descriptions say WHAT not WHEN — model picks wrong tool
- Using Buffer memory for long sessions — context fills, quality degrades
- Not feeding the observation back — agent repeats the same action
- Allowing tool errors to crash the loop — catch and pass as observation
