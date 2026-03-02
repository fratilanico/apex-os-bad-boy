---
name: webtricks-animated-pipeline
description: "Build animated data flow pipelines with SVG circuits, traveling dots, and ambient animations using Framer Motion + SVG. Use when visualizing architecture, workflows, API pipelines, or any step-by-step data flow. Tags: webtricks, animation, pipeline, SVG, architecture."
---

# Animated Pipeline Visualization — WebTricks

Create living, breathing pipeline visualizations with SVG circuit board styling, flowing dashes, traveling data packets, and ambient animations. For architecture diagrams, API flows, and data pipelines.

## When to Apply

- Visualizing API request → processing → response flows
- Building architecture diagrams that need to feel alive
- Showing data pipelines or ETL flows
- Any step-by-step process that benefits from animation

## Core Technique: SVG Animated Dash Lines

### CSS Keyframe (globals.css)

```css
@keyframes dashFlow {
  to {
    stroke-dashoffset: -28;
  }
}
```

### SVG Flowing Line

```tsx
<svg className="w-full h-full pointer-events-none" preserveAspectRatio="none">
  {/* Static background line */}
  <line x1="10%" y1="50%" x2="90%" y2="50%"
    stroke="rgba(63,63,70,0.4)" strokeWidth="2" />
  {/* Animated flowing dash line */}
  <line x1="10%" y1="50%" x2="90%" y2="50%"
    stroke="url(#flowGrad)" strokeWidth="2"
    strokeDasharray="8 6"
    className="animate-[dashFlow_2s_linear_infinite]" />
</svg>
```

### SVG Flow Connector Between Cards

```tsx
<div className="hidden md:flex items-center justify-center w-14 shrink-0">
  <svg width="56" height="24" viewBox="0 0 56 24" className="overflow-visible">
    {/* Background line */}
    <line x1="0" y1="12" x2="56" y2="12"
      stroke="rgba(63,63,70,0.5)" strokeWidth="2" />
    {/* Animated dash line */}
    <line x1="0" y1="12" x2="56" y2="12"
      stroke={color} strokeWidth="2"
      strokeDasharray="6 4"
      className="animate-[dashFlow_1.5s_linear_infinite]" />
    {/* Traveling dot */}
    <circle r="3" fill={color}>
      <animateMotion dur="1.5s" repeatCount="indefinite"
        path="M0,12 L56,12" />
    </circle>
    {/* Arrow head */}
    <polygon points="50,7 56,12 50,17" fill={color} opacity="0.8" />
  </svg>
</div>
```

## Per-Step Color System

Give each pipeline step its own color identity:

```tsx
const STEP_COLORS = [
  { bg: "rgba(34,197,94,0.1)", border: "rgba(34,197,94,0.3)",
    text: "text-green-400", glow: "shadow-green-500/20" },
  { bg: "rgba(59,130,246,0.1)", border: "rgba(59,130,246,0.3)",
    text: "text-blue-400", glow: "shadow-blue-500/20" },
  { bg: "rgba(168,85,247,0.1)", border: "rgba(168,85,247,0.3)",
    text: "text-purple-400", glow: "shadow-purple-500/20" },
  { bg: "rgba(249,115,22,0.1)", border: "rgba(249,115,22,0.3)",
    text: "text-orange-400", glow: "shadow-orange-500/20" },
  { bg: "rgba(236,72,153,0.1)", border: "rgba(236,72,153,0.3)",
    text: "text-pink-400", glow: "shadow-pink-500/20" },
];
```

### Data Flow Card Colors (Input → Tech → Output)

Use DIFFERENT colors for each role in the flow:

| Card | Color | Meaning |
|------|-------|---------|
| **Input** | Amber (`amber-500`) | Data arriving |
| **Technology** | Step's own color | The processing engine |
| **Output** | Emerald (`emerald-500`) | Result delivered |

```tsx
{/* Input — amber */}
<div className="bg-amber-500/5 border border-amber-500/20">
  <div className="text-amber-400">Input</div>
</div>

{/* Technology — step color */}
<div style={{ backgroundColor: color.bg, borderColor: color.border }}>
  <div className={color.text}>Technology</div>
</div>

{/* Output — emerald */}
<div className="bg-emerald-500/5 border border-emerald-500/20">
  <div className="text-emerald-400">Output</div>
</div>
```

## Ambient Animations

### Node Pulse Ring (Active Step)

```tsx
{isActive && (
  <motion.div
    className="absolute inset-0 rounded-xl border-2"
    style={{ borderColor: c.border }}
    animate={{ scale: [1, 1.3, 1.3], opacity: [0.6, 0, 0] }}
    transition={{ duration: 2, repeat: Infinity, ease: "easeOut" as const }}
  />
)}
```

### Breathing Glow (Icon Container)

```tsx
<motion.div
  className="w-10 h-10 rounded-xl flex items-center justify-center border"
  style={{ backgroundColor: color.bg, borderColor: color.border }}
  animate={{
    boxShadow: [
      `0 0 0px ${color.border}`,
      `0 0 16px ${color.border}`,
      `0 0 0px ${color.border}`,
    ]
  }}
  transition={{ duration: 2.5, repeat: Infinity }}
>
  <Icon className={`w-5 h-5 ${color.text}`} />
</motion.div>
```

### Scan Line (Processing Card)

```tsx
<motion.div
  className="absolute top-0 left-0 right-0 h-px"
  style={{ background: `linear-gradient(to right, transparent, ${color.border}, transparent)` }}
  animate={{ top: ["0%", "100%", "0%"] }}
  transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
/>
```

### Bottom Pulse Line

```tsx
<motion.div
  className="absolute bottom-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-amber-500/30 to-transparent"
  animate={{ opacity: [0, 1, 0] }}
  transition={{ duration: 2.5, repeat: Infinity, delay: 0.5 }}
/>
```

### Green Status Dot (Breathing)

```tsx
<motion.span
  className="w-1.5 h-1.5 rounded-full bg-green-500"
  animate={{ opacity: [1, 0.3, 1] }}
  transition={{ duration: 1.5, repeat: Infinity }}
/>
```

## Animated Timing Footer

Replace static "Total: ~2-10 seconds" with per-step timing pills:

```tsx
<div className="flex items-center gap-1.5">
  {PIPELINE.map((p, i) => (
    <div key={p.title} className="flex items-center gap-1.5">
      <motion.span
        className={`text-[9px] font-bold px-1.5 py-0.5 rounded ${
          i === step ? "bg-blue-600/20 text-blue-300" : "bg-zinc-800 text-zinc-500"
        }`}
        animate={i === step ? { opacity: [1, 0.6, 1] } : {}}
        transition={{ duration: 1.5, repeat: Infinity }}
      >
        {p.time}
      </motion.span>
      {i < PIPELINE.length - 1 && <span className="text-zinc-700">→</span>}
    </div>
  ))}
  <span className="text-zinc-700 mx-1">=</span>
  <motion.span
    className="text-xs font-black text-emerald-400"
    animate={{ opacity: [1, 0.5, 1] }}
    transition={{ duration: 2, repeat: Infinity }}
  >
    ~2-10s total
  </motion.span>
</div>
```

## Pipeline Data Structure

```tsx
const PIPELINE = [
  {
    icon: Key,
    title: "API Request",
    time: "~10ms",
    desc: "Your tool sends a JSON request to a single REST endpoint.",
    tech: "FastAPI + Uvicorn",
    input: "JSON payload + bearer token",
    output: "Authenticated request → agent",
  },
  // ... more steps
];
```

## Completed Node Indicator

```tsx
{isPast && (
  <div className="absolute -top-0.5 -right-0.5 w-2.5 h-2.5 bg-green-500 rounded-full border border-zinc-900" />
)}
```

## Checklist

- [ ] `@keyframes dashFlow` in globals.css
- [ ] Per-step colors defined outside component
- [ ] Input/Tech/Output have distinct color identities
- [ ] SVG connectors with animated dashes + traveling dots
- [ ] Active node has pulse ring animation (infinite loop)
- [ ] Completed nodes have green dot badge
- [ ] Breathing glow on active icon container
- [ ] Scan lines on processing cards
- [ ] Footer shows per-step timing breakdown
- [ ] Mobile fallback (vertical arrows instead of SVG connectors)
- [ ] All animations use `repeat: Infinity` (NOT one-shot)
