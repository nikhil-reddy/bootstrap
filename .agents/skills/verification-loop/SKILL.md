---
name: verification-loop
description: Use this skill to enforce a minimal verify loop for Terraform and Python.
origin: ECC (trimmed for Terraform + Python)
---

# Verification Loop Skill (Terraform + Python)

## When to Activate
- Any code change in Terraform or Python
- Before merge or release

## Minimal Loop
Run in this order:
```bash
terraform validate
black --check .
ruff
pytest
```

## If a step fails
- Fix and rerun until green
- If a tool is not installed, mention it and continue with remaining steps
