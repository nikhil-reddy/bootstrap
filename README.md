# bootstrap

Minimal terminal bootstrap script for macOS (Homebrew) and Debian/Ubuntu (apt).

## Usage
```sh
bash bootstrap.sh
```

## Common options
```sh
INSTALL_TERRAFORM=1 bash bootstrap.sh
INSTALL_TFENV=1 bash bootstrap.sh
INSTALL_CODEX_SKILLS=1 bash bootstrap.sh
INSTALL_FONTS=1 bash bootstrap.sh
INSTALL_STARSHIP=1 bash bootstrap.sh
```

## Codex skills
This repo includes a minimal set of Codex skills:
- security-review
- verification-loop
- coding-standards

Install them to your user profile with:
```sh
INSTALL_CODEX_SKILLS=1 bash bootstrap.sh
```

## Add a new skill or agent
### Add a skill
1. Create a new folder under `.agents/skills/<skill-name>/`.
2. Add `SKILL.md` with the instructions for that skill.
3. Optionally add `agents/openai.yaml` if the skill needs metadata.
4. Commit and push, then run:
```sh
INSTALL_CODEX_SKILLS=1 bash bootstrap.sh
```

### Add an agent
1. Create a new agent file under `.codex/agents/<agent-name>.toml`.
2. Reference it from your Codex config in `~/.codex/config.toml` under `[agents.<agent-name>]`.
3. Commit and push, then copy the config into `~/.codex/` on the target machine.
