---
name: tool-definition-patterns
description: Standards for defining AI agent tools based on Cline's system prompt patterns. Covers parameter typing, documentation, edit formats, safety mechanisms, and operational best practices.
tier: 2
tags: [tool-definition, ai-agents, coding-standards, documentation]
---

# Tool Definition Patterns

This skill establishes standards for defining AI agent tools, inspired by Cline's tool definition system. These patterns ensure consistent, safe, and usable tool interfaces.

---

## 1. Precise Parameter Types

Define required vs optional parameters explicitly in every tool definition.

### Required Parameters
- Mark with `(required)` in parameter description
- Must be provided for tool to execute
- List first in parameters section

### Optional Parameters
- Mark with `(optional)` in parameter description
- Specify default value behavior when omitted
- Group after required parameters

### Example from Cline

```
## execute_command
Parameters:
- command: (required) The CLI command to execute...
- requires_approval: (required) A boolean indicating whether this command...
```

---

## 2. Description + Usage Example

Every tool documentation MUST include both a clear description AND a concrete usage example.

### Description Requirements
- Explain what the tool accomplishes
- Specify when to use this tool vs alternatives
- Mention any automatic behaviors or side effects

### Usage Example Requirements
- Show actual XML-formatted tool call
- Include realistic parameter values
- Demonstrate complete invocation structure

### Example

```
## read_file
Description: Request to read the contents of a file at the specified path...
Parameters:
- path: (required) The path of the file to read...
Usage:
<read_file>
<path>src/main.js</path>
</read_file>
```

---

## 3. SEARCH/REPLACE Blocks

Standard edit format using exact matching for atomic changes.

### Format Specification

```
<<<<<< SEARCH
[exact content to find - character for character match]
=======
[new content to replace with]
>>>>>> REPLACE
```

### Critical Rules

1. **Exact matching**: SEARCH content must match file content exactly - whitespace, indentation, line endings
2. **First match only**: SEARCH/REPLACE replaces only first occurrence
3. **Concise blocks**: Keep blocks small - include just enough context for uniqueness
4. **Complete lines**: Never truncate lines mid-way

### Multi-Change Pattern

```
<<<<<< SEARCH
function add(a, b) {
  return a + b;
}
=======
function add(a: number, b: number): number {
  return a + b;
}
>>>>>> REPLACE

<<<<<< SEARCH
function multiply(a, b) {
  return a * b;
}
=======
function multiply(a: number, b: number): number {
  return a * b;
}
>>>>>> REPLACE
```

---

## 4. Rollback Capability

All destructive operations must have recovery mechanisms.

### Destructive Operations Include
- File deletion or overwrite
- Database schema changes
- System configuration modifications
- Network operations with side effects

### Recovery Patterns

1. **Backup before change**: Store original content for restore
2. **Version control integration**: Rely on git for file recovery
3. **Confirmation dialogs**: Require explicit approval for destructive actions
4. **Idempotent operations**: Design tools to be safely re-runnable

### Example - requires_approval flag

```
- requires_approval: (required) Set to 'true' for potentially impactful operations 
  like deleting/overwriting files, system configuration changes...
```

---

## 5. requires_approval Flag

Mark impactful operations to ensure human oversight.

### When to Set requires_approval: true

- File deletion or overwrite
- Installing/uninstalling packages
- System configuration changes
- Network operations
- Database write operations
- Commands that could have unintended side effects

### When to Set requires_approval: false

- Reading files or directories
- Running development servers
- Building projects
- Search operations
- Safe, non-destructive operations

### Example

```
<execute_command>
<command>rm -rf node_modules</command>
<requires_approval>true</requires_approval>
</execute_command>
```

---

## 6. Atomic Operation Expectations

Each tool should do ONE thing well.

### Atomic Design Principles

1. **Single responsibility**: One tool = one operation
2. **Composability**: Chain multiple tools for complex operations
3. **Predictable output**: Same input → same output
4. **No hidden state**: Tool should not depend on external state

### Non-Atomic Anti-Patterns

- Tool that reads AND writes in one call
- Tool with conditional behavior based on hidden flags
- Tool that modifies multiple unrelated resources

### Example - Atomic read_file

```
## read_file
Description: Request to read the contents of a file at the specified path.
(Does one thing - reads file content)
```

---

## 7. Regex-First Patterns

Use regex over glob for content search.

### Why Regex

- More precise pattern matching
- Supports capture groups
- Handles complex matching logic
- Standard syntax across tools

### Glob Limitations

- Limited to filename patterns only
- Cannot match content patterns
- Less expressive for complex searches

### Example - search_files

```
## search_files
Parameters:
- regex: (required) The regular expression pattern to search for. Uses Rust regex syntax.
- file_pattern: (optional) Glob pattern to filter files (e.g., '*.ts' for TypeScript files).
```

### Usage

```
<search_files>
<path>src/</path>
<regex>function\s+(\w+)\s*\(</regex>
<file_pattern>*.ts</file_pattern>
</search_files>
```

---

## 8. Context Window Awareness

Be mindful of file size and token limits.

### Best Practices

1. **Large files**: Read in chunks or use offset/limit
2. **Binary files**: Skip or use specialized tools
3. **Long outputs**: Truncate or summarize
4. **Token budgeting**: Consider context window limits

### Handling Large Files

- Use `offset` and `limit` parameters when available
- Read specific sections rather than entire files
- Consider grep for large file searches

### Example - list_files recursive flag

```
- recursive: (optional) Whether to list files recursively. Use true for recursive 
  listing, false or omit for top-level only.
```

---

## 9. Path Resolution Best Practices

Define absolute vs relative path handling clearly.

### Relative Paths

- Specify base directory (typically current working directory)
- Use consistent path normalization
- Document path resolution behavior

### Absolute Paths

- Use when paths are environment-independent
- Specify when full paths are required
- Consider platform differences (Windows vs Unix)

### Example from Cline

```
- path: (required) The path of the file to read (relative to the current working 
  directory ${cwd.toPosix()})
```

### Best Practices

1. **Normalize paths**: Use canonical path representations
2. **Platform-aware**: Handle OS-specific separators
3. **Clear base**: Always document the reference directory
4. **Posix format**: Use Posix-style paths for cross-platform compatibility

---

## 10. Error Recovery Patterns

Document how to recover from tool failures.

### Common Error Scenarios

1. **File not found**: Check path, use list_files to verify
2. **Permission denied**: Verify access rights, use alternative paths
3. **Parse errors**: Verify syntax, check for truncation
4. **Network failures**: Implement retry logic, timeout handling

### Recovery Strategies

1. **Graceful degradation**: Provide partial results when possible
2. **Clear error messages**: Include actionable recovery steps
3. **Idempotent operations**: Allow safe retry
4. **State verification**: Check state after operations

### Example - Multiple Tool Usage for Recovery

```
# If write fails, verify directory exists
<list_files>
<path>./</path>
</list_files>

# If search fails, try with broader pattern
<search_files>
<path>./</path>
<regex>pattern</regex>
</search_files>
```

### Documentation Pattern

Include error handling guidance in tool description:

```
May not be suitable for other types of binary files, as it returns the raw content 
as a string.
```

---

## Quick Reference

| Pattern | Key Point |
|---------|-----------|
| Parameter Types | Required (required) vs Optional (optional) |
| Documentation | Description + Usage Example always |
| Edits | SEARCH/REPLACE with exact matching |
| Safety | requires_approval for destructive ops |
| Scope | One tool = one atomic operation |
| Search | Regex over glob for content |
| Size | Context window awareness |
| Paths | Document relative/absolute base |
| Recovery | Document error handling |
| Rollback | Backup or version control for destructive ops |
