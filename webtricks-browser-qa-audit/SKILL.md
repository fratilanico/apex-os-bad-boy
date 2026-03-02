---
name: webtricks-browser-qa-audit
description: "Audit live websites using Playwright MCP for browser-based QA. Covers accessibility snapshots, screenshot verification, interactive element testing, and tier differentiation audits. Use after deploying web changes to verify they work. Tags: webtricks, QA, testing, playwright, audit."
---

# Browser-Based QA Audit — WebTricks

Use Playwright MCP to audit live deployed websites. Verify interactive elements work, content is correct, animations render, and tier differentiation functions properly.

## When to Apply

- After deploying changes to a live website
- When the user says something "doesn't work" or "is broken"
- Before presenting a site to a client
- When auditing tier/pricing functionality across multiple pages

## Audit Protocol

### Step 1: Full Slide/Page Audit

Navigate to the site and check EVERY page/slide systematically:

```
browser_navigate({ url: "https://site.vercel.app" })
browser_take_screenshot  → Landing page
browser_snapshot         → Get accessibility tree

// Navigate through all pages
browser_press_key({ key: "ArrowRight" })  // Next slide
browser_take_screenshot
browser_snapshot
// ... repeat for all pages
```

### Step 2: Interactive Element Verification

For each page, check:
1. **Are interactive elements real?** Check the accessibility tree for `<button>` vs `<span>`:
   - `button "Foundation · $5K"` = REAL button ✅
   - `text "Foundation $5K: 1 week"` with `cursor: auto` = FAKE, decorative ❌

2. **Do buttons respond to clicks?**
   ```
   browser_click({ ref: "eXX", element: "Foundation tier button" })
   browser_snapshot  → Did the content change?
   ```

3. **Does hover work?**
   ```
   browser_hover({ ref: "eXX", element: "Pipeline step node" })
   ```

### Step 3: Tier Differentiation Audit

For sites with tier selectors, verify EACH tier produces different content:

| Check | Method |
|-------|--------|
| Button is clickable | `browser_click` → verify response |
| Content changes | `browser_snapshot` before/after → compare |
| Count changes | e.g., "7 of 15" → "11 of 15" → "15 of 15" |
| Visual state changes | Cards lock/unlock, opacity changes |
| Correct labels | "Upgrade to Production" vs "Upgrade to Ecosystem" |

### Step 4: Viewport and Clipping Check

Common bugs to look for:
- **Buttons above viewport:** `items-center` on a tall page pushes top content above visible area
- **Scroll requirements:** Count how many items are visible without scrolling
- **Mobile vs desktop:** Check if elements hidden on mobile (`hidden md:flex`)

Use the accessibility snapshot to check element positions:
```yaml
# Look for negative positions or elements outside viewport
- button "Foundation" [ref=e42] [cursor=pointer]:
    # Check if this appears in the visible area
```

### Step 5: Console Errors

```
browser_console_messages
```
Zero errors = clean. Any errors = report immediately.

## Report Template

For each page/slide:

```markdown
## Slide X: [Name]

**Screenshot:** [description]
**Interactive elements:** [list all buttons/toggles/tabs]
**Tier differentiation:** [None / Works / Broken — details]

### What's broken:
- [specific issue with evidence]

### What works:
- [confirmed working elements]
```

## Common Failures to Check

| Failure | How to Detect |
|---------|--------------|
| Fake buttons (spans not buttons) | Accessibility tree shows `text` not `button` |
| Tier selector doesn't change content | Snapshot before/after click is identical |
| Content clipped above viewport | Elements with negative top positions |
| Hardcoded "Upgrade to Production" | Still says "Production" when on Production tier |
| Scripted demo labeled "CONNECTED" | Misleading status badges |
| Internal metrics shown as client outcomes | "18K+ leads" when client has zero leads |
| Price comparison that backfires | Competitor appears cheaper in the comparison |

## Checklist

- [ ] Every slide/page audited with screenshot + snapshot
- [ ] All interactive elements verified (click, hover, type)
- [ ] Tier selectors tested on EVERY slide that has them
- [ ] Content changes confirmed per tier (not just visual)
- [ ] Viewport clipping checked (no hidden buttons)
- [ ] Console errors checked (zero expected)
- [ ] Report generated with per-slide findings
