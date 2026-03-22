---
name: coding-standards
description: Use this skill to keep Terraform and Python code clean, safe, and consistent.
origin: ECC (trimmed for Terraform + Python)
---
## When to Activate

- Starting a new project or module
- Reviewing code for quality and maintainability
- Refactoring existing code to follow conventions
- Enforcing naming, formatting, or structural consistency
- Setting up linting, formatting, or type-checking rules
- Onboarding new contributors to coding conventions

## Code Quality Principles

### 1. Readability First
- Code is read more than written
- Clear variable and function names
- Self-documenting code preferred over comments
- Consistent formatting

### 2. KISS (Keep It Simple, Stupid)
- Simplest solution that works
- Avoid over-engineering
- No premature optimization
- Easy to understand > clever code

### 3. DRY (Don't Repeat Yourself)
- Extract common logic into functions
- Create reusable components
- Share utilities across modules
- Avoid copy-paste programming

### 4. YAGNI (You Aren't Gonna Need It)
- Don't build features before they're needed
- Avoid speculative generality
- Add complexity only when required
- Start simple, refactor when needed

## Terraform Standards
- Prefer small, composable modules
- Use variables and outputs consistently
- Avoid hardcoded secrets
- Keep resources least‑privilege
- `terraform validate` must pass

## Python standards
- Format with `black`
- Lint with `ruff`
- Write tests with `pytest`
- Avoid `eval`/`exec` for untrusted input
- No hardcoded credentials

## General
- Clear naming and minimal side effects
- Prefer explicitness over magic

*Remember**: Code quality is not negotiable. Clear, maintainable code enables rapid development and confident refactoring.
