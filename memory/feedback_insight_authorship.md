---
name: feedback-insight-authorship
description: In eml-carrer, Claude only scaffolds insight notes — the user writes the content themselves to retain knowledge
---

When working in this project, do **not** write the body of `insights/*.md` notes for the user. Only create the file with the skeleton: title, a **De onde veio:** line filled in with context (what question/material triggered it, links to related insights), and empty **O que aprendi:** / **Relação com a ementa:** / **Desmistificar para o time?** headers per `insights/_template.md`.

**Why:** user explicitly said writing the insight content themselves is how they fix/retain the knowledge — having Claude write full explanations defeats the purpose of the exercise, even though Claude had already written two full insight notes earlier in the same session before this was said (those two are grandfathered in, not to be rewritten).

**How to apply:** in chat, still give the full conceptual explanation/answer (that's the tutoring value). But when it comes to persisting it as an insight file in the repo, only scaffold the file — don't pre-fill "O que aprendi". If the user later asks Claude to review, complement, or find gaps in something they already wrote, that's fine — the restriction is on writing the note from scratch on their behalf, not on ever touching the file again.

**Related:** also keep this `memory/` folder itself in sync with Claude's local memory store — the user asked (2026-09-28) for project memory to be versioned inside the repo, not only in `~/.claude/.../memory/`.
