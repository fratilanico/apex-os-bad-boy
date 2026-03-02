---
name: performance-optimization
description: Use when Core Web Vitals are degraded, bundle size is too large, or React/Next.js rendering is slow — covers profiling, bundle analysis, and optimization patterns
tier: HIGH
value_tier: production
tags: [performance, web-vitals, optimization]
entitlements: { product_tiers: [all], agent_access: [all] }
---

# Performance Optimization Skill

## Core Web Vitals

### LCP (Largest Contentful Paint) < 2.5s
- Preload hero images
- Use next/image with proper sizes
- Font optimization with next/font
- Server-side render above-the-fold content

### CLS (Cumulative Layout Shift) < 0.1
- Reserve space for images/videos
- Use CSS aspect-ratio
- Font display: swap
- Avoid dynamically injected content

### FID/INP (First Input Delay/Interaction to Next Paint) < 100ms
- Code splitting
- Defer non-critical JS
- Minimize main thread work
- Use web workers for heavy computation

## Bundle Optimization

### Dynamic Imports
```typescript
const HeavyComponent = dynamic(() => import('./HeavyComponent'), {
  loading: () => <Skeleton />,
  ssr: false // Disable SSR if needed
})
```

### Bundle Analysis
```bash
npm run build && npm run analyze
```

## React Optimization

### useMemo & useCallback
```typescript
const memoizedValue = useMemo(() => computeExpensiveValue(a, b), [a, b])
const memoizedCallback = useCallback(() => doSomething(a), [a])
```

### React.memo
```typescript
const MyComponent = React.memo(({ title }) => {
  return <h1>{title}</h1>
})
```

## Image Optimization

### next/image
```typescript
import Image from 'next/image'

<Image
  src="/hero.jpg"
  alt="Hero"
  width={1200}
  height={600}
  priority // Preload LCP image
  sizes="(max-width: 768px) 100vw, 50vw"
/>
```

## Monitoring

### Real User Monitoring
- Vercel Analytics
- Google Core Web Vitals
- Custom performance marks
