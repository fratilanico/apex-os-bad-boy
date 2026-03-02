---
name: nextjs-production-bug-audit
description: Use when reviewing a Next.js marketing site or app for production readiness, before go-live, or when users report visual or functional bugs. Covers 26-point checklist across CRITICAL, HIGH, MEDIUM, LOW severity.
---

# Next.js Production Bug Audit

## Overview

Systematic bug-finding checklist for Next.js sites before or after deployment. Finds broken forms, dead links, mobile overflow, accessibility gaps, security issues, and content inconsistencies.

## When to Use

- Before deploying a Next.js site to production
- After user reports "something looks wrong"
- When inheriting a codebase and need to assess quality
- Quarterly production health checks

## Audit Procedure

1. **Run the build** — `npm run build` catches TypeScript errors and build failures
2. **Fetch the live page** — `curl -s https://site.com` and check content
3. **Read every component** — systematic file-by-file review
4. **Classify by severity** — CRITICAL (broken functionality) to LOW (polish)

## 26-Point Checklist

### CRITICAL — Blocks user actions

| # | Check | What to look for |
|---|-------|-----------------|
| 1 | **Form actions** | Placeholder URLs like `YOUR_FORM_ID`, `your-link`, `example.com` |
| 2 | **Auth security** | Raw passwords in cookies, missing httpOnly/secure flags |
| 3 | **Embed URLs** | Calendly/Stripe/third-party embeds pointing to profile pages not booking/checkout |
| 4 | **API endpoints** | Routes returning 500, missing env vars, broken integrations |

### HIGH — Major UX or data issues

| # | Check | What to look for |
|---|-------|-----------------|
| 5 | **Client vs Server components** | `notFound()` in `"use client"` (crashes), `useParams` where server props work |
| 6 | **Navigation links on sub-pages** | Hash links (`#contact`) that only work on homepage — need `/#contact` |
| 7 | **Semantic HTML** | Missing `<main>` wrapper, broken heading hierarchy |
| 8 | **Data consistency** | Same metric shown as different numbers across components |
| 9 | **metadataBase URL** | Pointing to `.vercel.app` instead of production domain |

### MEDIUM — Visual or mobile issues

| # | Check | What to look for |
|---|-------|-----------------|
| 10 | **Invalid Tailwind classes** | Non-standard opacity values (`bg-white/97`), deprecated utilities |
| 11 | **Mobile grid overflow** | `grid-cols-4` without responsive breakpoint on small screens |
| 12 | **Dead components** | Imported nowhere, adds to bundle for nothing |
| 13 | **Font variable mismatch** | CSS var named `--font-geist` loading Inter font |
| 14 | **Iframe error handling** | `onError` doesn't fire for HTTP errors, only network failures |
| 15 | **Footer dead links** | Privacy Policy, Terms, GitHub, LinkedIn as `<span>` not `<a>` |
| 16 | **Carousel indicators** | Dots not tracking scroll position correctly |

### LOW — Polish and best practices

| # | Check | What to look for |
|---|-------|-----------------|
| 17 | **Missing `rel="noopener"`** | External links without `target="_blank" rel="noopener noreferrer"` |
| 18 | **Missing aria-labels** | Password inputs, icon buttons, carousel dots without labels |
| 19 | **Suspense without fallback** | `<Suspense>` with no `fallback` prop = blank flash |
| 20 | **`<a>` vs `next/link`** | Internal links causing full page reloads |
| 21 | **Stale closures in effects** | `useEffect` deps missing callback references |
| 22 | **Fixed elements on light sections** | Dark-themed fixed nav dots invisible over white sections |
| 23 | **Email inconsistency** | Different contact emails on different pages |
| 24 | **Console.log in production** | Debug statements left in shipped code |
| 25 | **Missing env var handling** | `process.env.X` used without undefined fallback |
| 26 | **Middleware auth bypass** | `pathname.includes('.')` letting crafted paths through |

## Quick Commands

```bash
# Build check
npm run build 2>&1 | tail -20

# TypeScript check
npx tsc --noEmit

# Fetch and check live content
curl -s https://site.com | grep -o 'YOUR_FORM_ID\|your-link\|example\.com\|TODO\|FIXME\|lorem'

# Check all hash links
grep -rn 'href="#' src/components/ | grep -v node_modules

# Find dead imports
grep -rn 'from.*@/components' src/ | sed 's/.*from.*@\/components\///' | sort | uniq -c | sort -n

# Check for console.log
grep -rn 'console\.log' src/ --include='*.tsx' --include='*.ts' | grep -v node_modules
```

## Content Credibility Check

When a site claims "real production numbers", verify consistency:

```bash
# Find all instances of a claimed metric
grep -rn '3,849\|3,816\|3849\|3816' src/
# Every file should show the SAME number
```

Inconsistent metrics destroy credibility for a site that emphasizes "real data, not benchmarks."

## Common Mistakes

| Mistake | Why it happens | Fix |
|---------|---------------|-----|
| `notFound()` in client component | Developer adds `"use client"` for hooks | Convert to server component, extract interactive parts |
| Hash links break on sub-pages | Works on homepage, never tested from /course | Use absolute paths: `/#section` |
| Placeholder form URLs shipped | Developer planned to add Formspree later, forgot | Search for `YOUR_`, `your-`, `example.com` before deploy |
| Showing cost structure to customers | "Transparency builds trust" | It undermines pricing — save for investor decks |

*Last updated: 2026-02-23. Derived from a 26-bug audit of a real Next.js production site.*
