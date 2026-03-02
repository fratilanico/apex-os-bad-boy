---
name: code-edit-quality
description: SEARCH/REPLACE block patterns for precise code edits. Based on Cline's edit methodology for accurate file modifications.
tier: essential
tags: [editing, code-quality, search-replace, refactoring]
---

# Code Edit Quality

Master the art of precise code modifications using SEARCH/REPLACE blocks.

---

## 1. Minimal SEARCH Block

Only include changing lines plus 2-3 context lines for uniqueness.

```
# Wrong - Too much unchanged code
<<<<<<< SEARCH
function calculateTotal(items) {
  let total = 0;
  for (let i = 0; i < items.length; i++) {
    total += items[i].price;
  }
  return total;
}

function formatCurrency(amount) {
  return `$${amount.toFixed(2)}`;
}
=======
function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.price, 0);
}

function formatCurrency(amount) {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount);
}
>>>>>>> REPLACE

# Right - Minimal SEARCH block
<<<<<<< SEARCH
function calculateTotal(items) {
  let total = 0;
  for (let i = 0; i < items.length; i++) {
    total += items[i].price;
  }
  return total;
}
=======
function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.price, 0);
}
>>>>>>> REPLACE
```

---

## 2. Unique Match Verification

Confirm SEARCH matches exactly one location before applying.

```
# Verify uniqueness with grep first
grep -n "function calculateTotal" src/

# Then use unique SEARCH block
<<<<<<< SEARCH
function calculateTotal(items) {
  let total = 0;
=======
function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.price, 0);
}
>>>>>>> REPLACE
```

---

## 3. Multi-Block Ordering

List SEARCH/REPLACE blocks in file order for sequential changes.

```
# File order: top to bottom
<<<<<<< SEARCH
const API_URL = 'http://localhost:3000';
=======
const API_URL = process.env.API_URL || 'http://localhost:3000';
>>>>>>> REPLACE

<<<<<<< SEARCH
function fetchUser(id) {
  return fetch(`/api/users/${id}`);
}
=======
async function fetchUser(id) {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}
>>>>>>> REPLACE
```

---

## 4. Whitespace Sensitivity

Preserve exact indentation - spaces and tabs matter.

```
# Wrong - Wrong indentation
<<<<<<< SEARCH
function hello() {
console.log('hello');
}
=======
function hello() {
    console.log('hello');
}
>>>>>>> REPLACE

# Right - Exact whitespace match
<<<<<<< SEARCH
function hello() {
console.log('hello');
}
=======
function hello() {
  console.log('hello');
}
>>>>>>> REPLACE
```

---

## 5. Line Completeness

Never truncate lines mid-way - include complete line content.

```
# Wrong - Truncated line
<<<<<<< SEARCH
const users = await db.query('SELECT * FROM users WHERE
=======
const users = await db.query('SELECT * FROM users WHERE active = true');
>>>>>>> REPLACE

# Right - Complete lines
<<<<<<< SEARCH
const users = await db.query('SELECT * FROM users WHERE active = true');
=======
const users = await db.query('SELECT * FROM users WHERE active = $1', [true]);
>>>>>>> REPLACE
```

---

## 6. Comment Preservation

Keep existing comments in replacements - they're part of the code's context.

```
# Wrong - Removed comment
<<<<<<< SEARCH
// Calculate total price
function calculateTotal(items) {
=======
function calculateTotal(items) {
>>>>>>> REPLACE

# Right - Preserve comments
<<<<<<< SEARCH
// Calculate total price including tax
function calculateTotal(items) {
=======
// Calculate total price including tax
function calculateTotal(items) {
>>>>>>> REPLACE
```

---

## 7. Move Operation: Delete + Insert

Use two SEARCH/REPLACE blocks for moving code - delete then insert.

```
# Step 1: Delete from original location
<<<<<<< SEARCH
function oldUtility() {
  // deprecated
}
=======
>>>>>>> REPLACE

# Step 2: Insert at new location
<<<<<<< SEARCH
function processData() {
=======
function processData() {

function oldUtility() {
  // deprecated
}
>>>>>>> REPLACE
```

---

## 8. Empty Replace for Deletions

Use empty REPLACE section to remove code.

```
# Delete unused import
<<<<<<< SEARCH
import { unusedFunction } from './utils';
=======
>>>>>>> REPLACE

# Delete entire function
<<<<<<< SEARCH
function unusedHelper() {
  return 'not used';
}
=======
>>>>>>> REPLACE
```

---

## 9. Conflict Resolution

For overlapping edits, refactor into non-overlapping blocks.

```
# Problem: Two edits overlap
# Edit 1 changes lines 5-10
# Edit 2 changes lines 8-15 (overlaps!)

# Solution: Consolidate into single SEARCH/REPLACE
<<<<<<< SEARCH
function processUser(input) {
  const name = input.name;
  const email = input.email;
  return { name, email };
}

function validateEmail(email) {
  return email.includes('@');
}
=======
async function processUser(input) {
  const name = input.name?.trim();
  const email = input.email?.trim().toLowerCase();
  
  if (!validateEmail(email)) {
    throw new Error('Invalid email');
  }
  
  return { name, email };
}

function validateEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}
>>>>>>> REPLACE
```

---

## 10. Preview Before Apply

Verify changes match expected pattern before committing.

```
# Before applying, verify:
# 1. SEARCH matches exactly one location
grep -c "exact search string" file.ts
# Should return 1

# 2. Read the file to confirm context
read -l 10:20 file.ts

# 3. Compare SEARCH content matches file exactly
# Then apply SEARCH/REPLACE
```

---

## Quick Reference

| Operation | Pattern |
|-----------|---------|
| Replace | `SEARCH` + `REPLACE` |
| Delete | `SEARCH` + empty `REPLACE` |
| Move | Delete + Insert (two blocks) |
| Multiple | Multiple SEARCH/REPLACE blocks in file order |
