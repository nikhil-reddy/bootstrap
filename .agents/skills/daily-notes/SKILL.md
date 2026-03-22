---
name: daily-notes
description: Clean up daily notes into a consistent summary with decisions, actions, blockers, open questions, and next steps.
origin: custom
---

# Daily Notes Skill

Turn raw daily notes into a clean, consistent log.

## When to Activate
- User says: "clean up today’s notes", "summarize my notes", "daily log"
- Given a block of messy notes or meeting scraps

## Output Format
Use this exact template (Markdown):

```md
# YYYY-MM-DD

## Summary
- ...

## Decisions
- ...

## Actions
- [ ] ...

## Blockers
- ...

## Open Questions
- ...

## Notes (cleaned)
- ...
```

## Rules
- Preserve facts; don’t invent details.
- Pull action items from the notes; if unclear, tag as "(needs owner)".
- If a section is empty, keep the header and write "- None".
- Keep summary to 3–5 bullets.
