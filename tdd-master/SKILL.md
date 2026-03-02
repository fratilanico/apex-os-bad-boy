---
name: tdd-master
description: Use when implementing any feature or bugfix in React/Next.js — writes failing tests first with Jest and Testing Library before touching implementation code
tier: HIGH
value_tier: production
tags: [testing, tdd, jest, quality]
entitlements: { product_tiers: [all], agent_access: [all] }
---

# TDD Mastery Skill

## Test Pyramid
```
       /\
      /E2E\        ← Few, expensive, critical paths
     /------\
    /Integration\  ← API, components
   /------------\
  /    Unit       \ ← Many, fast, isolated
 /________________\
```

## Testing Patterns

### Component Test
```typescript
import { render, screen, fireEvent } from '@testing-library/react'
import { MyComponent } from './MyComponent'

describe('MyComponent', () => {
  it('renders correctly', () => {
    render(<MyComponent title="Test" />)
    expect(screen.getByText('Test')).toBeInTheDocument()
  })

  it('handles click', () => {
    const onClick = jest.fn()
    render(<MyComponent onClick={onClick} />)
    fireEvent.click(screen.getByRole('button'))
    expect(onClick).toHaveBeenCalled()
  })
})
```

### Hook Testing
```typescript
import { renderHook, act } from '@testing-library/react'
import { useCounter } from './useCounter'

it('increments counter', () => {
  const { result } = renderHook(() => useCounter())
  
  act(() => {
    result.current.increment()
  })
  
  expect(result.current.count).toBe(1)
})
```

### Async Testing
```typescript
it('fetches data', async () => {
  const mockData = { id: 1, name: 'Test' }
  fetch.mockResolvedValueOnce({ json: () => Promise.resolve(mockData) })
  
  render(<DataComponent />)
  
  await waitFor(() => {
    expect(screen.getByText('Test')).toBeInTheDocument()
  })
})
```

## Mock Patterns

### Module Mocking
```typescript
jest.mock('./api', () => ({
  fetchUser: jest.fn()
}))
```

### MSW (Mock Service Worker)
```typescript
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

export const server = setupServer(...handlers)

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```
