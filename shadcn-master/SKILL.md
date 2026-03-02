---
name: shadcn-master
description: Shadcn UI, Radix UI, and Tailwind CSS component patterns for enterprise applications
tier: HIGH
value_tier: production
tags: [ui, components, shadcn, tailwind, radix]
entitlements: { product_tiers: [all], agent_access: [all] }
---

# Shadcn UI Mastery

## Component Philosophy

- Copy/paste components (not npm dependency)
- Full control over code
- Easy customization
- Type-safe with TypeScript

## Common Patterns

### Button Variants
```typescript
<Button variant="default">Default</Button>
<Button variant="destructive">Destructive</Button>
<Button variant="outline">Outline</Button>
<Button variant="secondary">Secondary</Button>
<Button variant="ghost">Ghost</Button>
<Button variant="link">Link</Button>
```

### Form with React Hook Form + Zod
```typescript
const form = useForm<z.infer<typeof formSchema>>({
  resolver: zodResolver(formSchema),
  defaultValues: { email: '' }
})

<FormField
  control={form.control}
  name="email"
  render={({ field }) => (
    <FormItem>
      <FormLabel>Email</FormLabel>
      <FormControl>
        <Input {...field} />
      </FormControl>
      <FormMessage />
    </FormItem>
  )}
/>
```

### Responsive Design
```typescript
// Mobile first approach
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
  {/* Content */}
</div>
```

## Accessibility

- Use Radix UI primitives
- Proper ARIA labels
- Keyboard navigation
- Focus management
- Screen reader support
