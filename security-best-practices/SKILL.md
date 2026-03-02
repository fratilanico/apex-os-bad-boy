---
name: security-best-practices
description: Security best practices for React/Next.js - XSS, CSRF, authentication, and API security
tier: CRITICAL
value_tier: production
tags: [security, authentication, best-practices]
entitlements: { product_tiers: [all], agent_access: [all] }
---

# Security Best Practices

## Authentication

### Secure Session Management
- Use HTTP-only, Secure cookies
- Implement CSRF protection
- Set appropriate cookie expiry
- Rotate tokens regularly

### Password Handling
- Never store plain text passwords
- Use strong hashing (bcrypt, argon2)
- Implement rate limiting on login
- Add captcha for failed attempts

## Data Protection

### Input Validation
```typescript
import { z } from 'zod'

const UserSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(100),
  name: z.string().max(100)
})
```

### SQL Injection Prevention
- Use parameterized queries
- Never concatenate user input to queries
- Use ORM/Query Builder

## XSS Prevention

### React Protection
- React escapes by default
- Use dangerouslySetInnerHTML sparingly
- Sanitize user input
- Use Content Security Policy

## API Security

### Rate Limiting
```typescript
import { rateLimit } from './lib/rate-limit'

export async function POST(req: Request) {
  const ip = req.headers.get('x-forwarded-for') || 'unknown'
  const { success } = await rateLimit.limit(ip)
  
  if (!success) {
    return new Response('Too Many Requests', { status: 429 })
  }
  // Process request
}
```

### CORS Configuration
```typescript
// Only allow specific origins
export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', 'https://yoursite.com')
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
  res.setHeader('Access-Control-Allow-Credentials', 'true')
}
```

## Environment Variables

- Never commit secrets to git
- Use .env.local for local development
- Use Vercel env vars for production
- Prefix sensitive variables (e.g., NEXT_PUBLIC_ only for public)
