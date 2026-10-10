---
name: user-profile
description: "User's background and goal for the eml-carrer study project — senior SWE studying for an internal ML Engineering exam"
metadata:
  node_type: memory
  originSessionId: 73f5b50a-4f93-41b7-a13e-dc08341d3a9f
  modified: 2026-10-10T17:13:06.907Z
---

User is a **senior software engineer** (domain: general software engineering — architecture, code, testing, CI/CD, containers, git, agile — fully solid). They already work on an **EML (Engenharia de Machine Learning) team** at a bank.

They are studying for the bank's internal **EML career exam/sabatina** (same written exam for all levels; oral "sabatina" varies by level). Their self-identified gap is **not software engineering but ML/MLOps-specific concepts**: Model Registry, Feature Store, Feature Engineering, ML itself, MLOps solution design.

Secondary goal beyond passing the exam: they want to **demystify certain EML/MLOps concepts for their own team** — so insights worth sharing with teammates should be flagged, not just filed away privately.

Communicates in Portuguese (Brazilian). Prefers simple, incremental structure — "vamos ser simples, com base na necessidade vamos incrementando" — avoid over-building structure before it's needed.

**Learning goals added 2026-10-09 (tracked in `add-ons.md`, not the official `ementa.md`):** AWS best practices (IAM, CLI setup, credential security — least privilege, roles vs. users, MFA/SSO) and idiomatic Terraform (module structure, remote state, variables/outputs, provider versioning). Both surfaced from the hands-on data mesh exercise (see [[project_context]]) — user deliberately wants to learn the "right way" to do `aws configure`/IAM *before* running it, not just get credentials working quickly. Teach these in chat as they come up during the infra work, same tutoring convention as everything else in this repo. On 2026-10-10 the user explicitly asked to step back into a disposable Terraform sandbox to fix real gaps in how Terraform works mechanically before continuing — see [[terraform_fundamentals_covered]].

See [project_context.md](project_context.md) for the concrete repo/workflow this feeds into.
