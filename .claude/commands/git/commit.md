---
description: Create a git commit
model: claude-3-5-haiku-20241022
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Commit Format

Use Conventional Commits

```
<type>: <description>

[optional body]
[optional footer]
```

### Types

- `feat:` - New feature
- `fix:` - Bug fix
- `perf:` - Performance improvement
- `docs:` - Documentation
- `test:` - Tests
- `build:` - Build system
- `chore:` - Maintenance

## Your task

Based on the above changes, create a single git commit. Don't add any files we did not generate in this session. Commit files that are already staged or were created in this session.
