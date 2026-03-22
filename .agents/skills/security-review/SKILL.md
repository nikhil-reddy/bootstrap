---
name: security-review
description: Use this skill when changing Terraform IaC or Python services/scripts that touch credentials, data access, or security controls.
origin: ECC (trimmed for Terraform + Python)
---

# Security Review Skill (Terraform + Python)

This skill focuses on security review for infrastructure‑as‑code and Python codebases.

## When to Activate
- Any Terraform change (modules, providers, state, backend, IAM)
- Any Python change that touches auth, secrets, crypto, or data access
- CI/CD or deployment pipeline changes

## Terraform Security Checklist
- [ ] No secrets in `.tf`, `.tfvars`, or state files
- [ ] Use variables for sensitive values and keep them out of VCS
- [ ] Backend state is remote and encrypted (if applicable)
- [ ] IAM is least‑privilege (no wildcard `*` where avoidable)
- [ ] Security‑sensitive resources reviewed (networks, IAM, KMS, secrets)
- [ ] `terraform validate` passes

## Python Security Checklist
- [ ] Secrets only from environment or secret manager
- [ ] No hardcoded tokens, passwords, or keys
- [ ] Input validation on untrusted data
- [ ] Safe file handling (no path traversal)
- [ ] Avoid dangerous eval/exec patterns
- [ ] `pytest` passes
- [ ] `ruff` passes
- [ ] `black` formatting

## Pre‑merge Verification
Run the minimal security loop:
```bash
terraform validate
pytest
ruff
black --check .
```

## Notes
- Keep checks cloud‑agnostic; focus on least privilege, secret hygiene, and safe defaults.
- If a repo has no Terraform or Python, skip this skill.
