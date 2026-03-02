---
name: supabase-expert
description: Use when building or debugging Supabase features — RLS policies, Auth flows, Storage rules, Edge Functions, and real-time subscriptions
tier: HIGH
value_tier: production
tags: [supabase, postgresql, auth, rls, database]
entitlements: { product_tiers: [pro, enterprise], agent_access: [all] }
---

# Supabase Expert Skill

## Database Schema

### RLS Policies
```sql
-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read own profile
CREATE POLICY "Users can view own profile"
ON profiles FOR SELECT
USING (auth.uid() = user_id);

-- Policy: Users can update own profile
CREATE POLICY "Users can update own profile"
ON profiles FOR UPDATE
USING (auth.uid() = user_id);
```

### Relationships
- Use foreign keys for all relationships
- Add indexes on frequently queried columns
- Consider partial indexes for permission filtering

## Authentication

### Secure Flow
```typescript
// Sign up with email confirmation
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'secure-password',
  options: {
    emailRedirectTo: 'https://yoursite.com/auth/callback'
  }
})
```

### Session Management
```typescript
// Check current session
const { data: { session } } = await supabase.auth.getSession()

// Listen for auth changes
supabase.auth.onAuthStateChange((event, session) => {
  if (event === 'SIGNED_IN') {
    // Handle sign in
  }
})
```

## Edge Functions

### Deno Runtime
```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!)
  // Your logic here
})
```

## Storage

### Bucket Management
```typescript
// Upload file
const { data, error } = await supabase.storage
  .from('avatars')
  .upload('folder/filename', file)
```

## Real-time

### Subscribe to Changes
```typescript
const subscription = supabase
  .channel('custom-insert-channel')
  .on('postgres_changes', { 
    event: 'INSERT', 
    schema: 'public', 
    table: 'messages' 
  }, (payload) => {
    console.log('New message:', payload.new)
  })
  .subscribe()
```

## Performance

### Query Optimization
- Select only needed columns
- Use .single() for single row queries
- Implement pagination for large datasets
- Add proper indexes
