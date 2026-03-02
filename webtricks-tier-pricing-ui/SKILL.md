---
name: webtricks-tier-pricing-ui
description: "Build interactive tier-based pricing UI with lock/unlock states, progressive disclosure, and cross-slide consistency. Use when building pricing pages, tier selectors, or feature comparison grids. Tags: webtricks, pricing, tiers, SaaS."
---

# Tier-Based Pricing UI — WebTricks

Build interactive pricing UIs where deliverables, features, and timelines change based on selected tier. Includes lock/unlock states, tier-aware messaging, and cross-slide consistency.

## When to Apply

- Building pricing pages with multiple tiers
- Creating feature comparison grids
- Building proposal sites where deliverables vary by tier
- Any UI where content visibility depends on a selected plan

## Core Pattern: Tier Selector + Deliverable Grid

### Data Structure

```tsx
type Tier = "foundation" | "production" | "ecosystem";

const DELIVERABLES = [
  {
    icon: Cloud,
    title: "Production Azure VM",
    desc: "Dedicated VM on your tenant. You own the machine.",
    tiers: ["foundation", "production", "ecosystem"] as Tier[],
    phase: "Day 1-2",  // Cross-reference to build timeline
  },
  {
    icon: Shield,
    title: "Security Hardening",
    desc: "SSL/TLS, key rotation, IP whitelisting, audit logging.",
    tiers: ["production", "ecosystem"] as Tier[],  // Not in Foundation
    phase: "Day 5-6",
  },
  // ...
];

const TIER_OPTIONS = [
  { id: "foundation" as Tier, label: "Foundation", price: "$5K" },
  { id: "production" as Tier, label: "Production", price: "$9K" },
  { id: "ecosystem" as Tier, label: "Full Ecosystem", price: "$15K" },
];
```

### Tier Selector Buttons

```tsx
<div className="flex justify-center gap-2 mb-5">
  {TIER_OPTIONS.map((t) => (
    <button
      key={t.id}
      onClick={() => setTier(t.id)}
      className={`px-4 py-2 rounded-lg text-xs font-bold transition-all ${
        tier === t.id
          ? "bg-blue-600 text-white shadow-lg shadow-blue-600/20"
          : "bg-zinc-900 text-zinc-400 hover:text-white border border-zinc-800"
      }`}
    >
      {t.label} · {t.price}
    </button>
  ))}
</div>
```

**CRITICAL:** These MUST be `<button>` elements, not `<span>` or `<div>`. Decorative elements that look like buttons but don't respond to clicks are a major UX failure.

### Lock/Unlock Card Rendering

```tsx
{DELIVERABLES.map((d, i) => {
  const included = d.tiers.includes(tier);
  const lowestTier = d.tiers[0];
  const upgradeTo = lowestTier === "production" ? "Production" : "Ecosystem";

  return (
    <motion.div
      key={d.title}
      animate={{ opacity: included ? 1 : 0.25, scale: included ? 1 : 0.98 }}
      className={`rounded-xl p-5 border transition-colors duration-300 ${
        included
          ? "bg-blue-600/5 border-blue-500/20"
          : "bg-zinc-900/50 border-zinc-800/50"
      }`}
    >
      <div className="flex items-start justify-between mb-3">
        <d.icon className={`w-5 h-5 ${included ? "text-blue-400" : "text-zinc-700"}`} />
        <div className="flex items-center gap-2">
          {/* Phase badge — connects to build timeline */}
          <span className={`text-[9px] font-bold px-2 py-0.5 rounded-full ${
            included ? "text-zinc-500 bg-zinc-800/80" : "text-zinc-700 bg-zinc-800/40"
          }`}>{d.phase}</span>
          {included ? (
            <CheckCircle2 className="w-4 h-4 text-blue-500" />
          ) : (
            <Lock className="w-3.5 h-3.5 text-zinc-700" />
          )}
        </div>
      </div>
      <h3 className={`text-sm font-black mb-1.5 ${included ? "text-white" : "text-zinc-600"}`}>
        {d.title}
      </h3>
      <p className={`text-xs leading-relaxed ${included ? "text-zinc-400" : "text-zinc-700"}`}>
        {d.desc}
      </p>
      {/* Tier-aware upgrade prompt */}
      {!included && (
        <div className="mt-2 text-[10px] font-bold text-zinc-600">
          Upgrade to {upgradeTo} to unlock
        </div>
      )}
    </motion.div>
  );
})}
```

### Counter

```tsx
const includedCount = DELIVERABLES.filter((d) => d.tiers.includes(tier)).length;
// Display: "7 of 15 deliverables included"
```

## Rules

### 1. Tier-Aware Upgrade Text
Don't hardcode "Upgrade to Production to unlock" everywhere. Calculate the correct next tier:
- Foundation viewing Production item → "Upgrade to Production"
- Foundation viewing Ecosystem item → "Upgrade to Ecosystem"
- Production viewing Ecosystem item → "Upgrade to Ecosystem"

### 2. Progressive Visual Feedback
- Foundation: ~40% of cards active → feels like a starter pack
- Production: ~70% active → feels like the sweet spot
- Ecosystem: 100% active → feels complete
- The visual progression should make Production feel like the obvious choice

### 3. Cross-Slide Consistency
If you have a Build Plan slide AND a What You Get slide AND a Pricing slide, the tiers must:
- Show the SAME tier names everywhere
- Use the SAME colors for each tier
- Show consistent deliverables (don't list 7 items on pricing but 15 on deliverables)
- Link build phases to deliverables via phase badges

### 4. Pricing Columns Pattern
```tsx
<div className="grid md:grid-cols-3 gap-4">
  {/* Non-recommended tier */}
  <div className="bg-zinc-900 border border-zinc-800 rounded-2xl p-5">
    <ul>
      {items.map(f => (
        <li className="flex gap-2 text-xs text-zinc-400">
          <CheckCircle2 className="w-3.5 h-3.5 text-zinc-600" />{f}
        </li>
      ))}
    </ul>
  </div>

  {/* Recommended tier — blue accent + badge */}
  <div className="bg-blue-600/5 border border-blue-500/20 ring-1 ring-blue-500/10 rounded-2xl p-5 relative">
    <div className="absolute top-0 right-0 bg-blue-600 text-white px-2.5 py-0.5 rounded-bl-lg rounded-tr-xl text-[9px] font-black uppercase">
      Recommended
    </div>
    {/* Blue checkmarks */}
  </div>
</div>
```

### 5. Support Tier Strategy
Never show only the highest support price. Show tiers:
- **Free:** 30 days included post-build
- **Standard ($500/mo):** Maintenance, troubleshooting, monthly check-in
- **Premium ($1,500/mo):** New skills, governance, SLA, dedicated channel

### 6. Avoid Comparison Traps
Never compare your price directly to a cheaper competitor:
- ❌ "ChatGPT Plus 5 seats = $100/mo" vs "Your agent = $200/mo" (competitor wins on price)
- ✅ "What you get for ~$250/mo: full autonomous agent, API access, your infrastructure"

## Checklist

- [ ] Tier buttons are real `<button>` elements
- [ ] Lock/unlock visuals are clear (opacity + icon + upgrade text)
- [ ] Upgrade text is tier-aware (not hardcoded)
- [ ] Counter shows "X of Y included"
- [ ] Phase badges link deliverables to build timeline
- [ ] Recommended tier has visual emphasis (blue, badge)
- [ ] Support pricing shows tiers, not just the top price
- [ ] No direct competitor price comparisons that backfire
