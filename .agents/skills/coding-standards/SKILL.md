---
name: coding-standards
description: Use this skill to keep Terraform and Python code clean, safe, and consistent.
origin: ECC (trimmed for Terraform + Python)
---

# Coding Standards (Terraform + Python)

## Terraform
- Prefer small, composable modules
- Use variables and outputs consistently
- Avoid hardcoded secrets
- Keep resources least‑privilege
- `terraform validate` must pass

## Python
- Format with `black`
- Lint with `ruff`
- Write tests with `pytest`
- Avoid `eval`/`exec` for untrusted input
- No hardcoded credentials

## General
- Clear naming and minimal side effects
- Prefer explicitness over magic
