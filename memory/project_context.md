---
name: eml-carrer-project
description: "Structure, purpose, and workflow of the eml-carrer git repo — study base for the EML exam"
metadata:
  node_type: memory
  originSessionId: 73f5b50a-4f93-41b7-a13e-dc08341d3a9f
  modified: 2026-10-10T17:14:25.732Z
---

Repo: `C:\Users\Lunam\www\eml-carrer`, git-initialized locally.

**Purpose:** versioned personal knowledge base to study for the bank's EML (Engenharia de Machine Learning) exam, built incrementally in collaboration with Claude across sessions. See [user_profile.md](user_profile.md) for who this is for and why.

**Structure:**
- `README.md` — context: user's profile, the team's role (self-service ML deployment platforms, framework homologation, data scientist enablement, architecture/cloud/security/governance integration), and the repo's workflow.
- `ementa.md` — the exam syllabus, one section per topic, each with **3 independent checkboxes**: `Domino` / `Preciso reforçar` / `Não sei`. Filled in by the user on 2026-09-28.
- `materiais.md` — the exam's official supporting materials, organized by theme with read-status checkboxes.
- `insights/` — dated insight notes. **Content is written by the user, not Claude** — see [feedback_insight_authorship.md](feedback_insight_authorship.md). Claude only scaffolds the file (title, "De onde veio" context, empty headers) from `insights/_template.md`.
- `memory/` — this folder: versioned copy of Claude's project memory, kept in sync with the local `~/.claude/.../memory/` store.
- `add-ons.md` — subjects outside the official ementa but conceptually load-bearing for it (created 2026-09-29). First batch: Data Lake, Data Warehouse, Data Mesh. Later added (2026-10-09): AWS best practices (IAM/CLI) and idiomatic Terraform, as personal learning goals surfaced by the hands-on exercise below — see [[user_profile]]. Same 3-checkbox self-assessment convention as `ementa.md`.
- `roadmap.md` — not yet created; comes next, prioritized by the filled-in `ementa.md` (Não sei > Preciso reforçar > review of Domino topics).

**Ementa self-assessment as of 2026-09-28** (for quick reference — check the live file for current state):
- **Domino:** Python (lógica), Teste de Software, SQL, Modelagem de dados transacional, Manipulação de Dados não Estruturados, Docker, Git, Conceitos de Aplicação Web.
- **Preciso reforçar:** Engenharia/Ingestão de Dados, Linux, Metodologia Ágil, Infra as Code, Arquitetura de Nuvem, AWS.
- **Não sei:** Big Data, Desenho de solução para MLOps, CI/CD para ML, Model Registry, Feature Store, Feature Engineering, Geração de gráficos, Aprendizagem de Máquina.

**Insights written so far:**
- `2026-09-28-taxonomia-times-de-dados.md` — full note (Claude-authored, before the authorship convention changed).
- `2026-09-28-arquitetura-sor-sot-spec-feature-store.md` — full note (Claude-authored, before the authorship convention changed). Covers the user's real architecture: times transacionais → SoR (S3+Glue) → ED (ETL) → SoT/Spec → CD (modelos/books) or direct from SoR → EML plataforma (books + modelos) → camada fast (DynamoDB) → API Golang. Maps to Feature Store reference architecture (offline/online store), medallion architecture (Bronze/Silver/Gold ≈ SoR/SoT/Spec), and flags that Feature Store ownership overlapping with ED is a recognized industry pattern, not a boundary violation — governance of duplicated transform logic is the real risk.
- `2026-09-28-model-registry-na-plataforma.md` — **skeleton only**, waiting for the user to write it (open question: does a formal Model Registry exist before the platform's serving layer?).

**Workflow:**
1. User self-assesses `ementa.md` checkboxes. (Done 2026-09-28.)
2. Claude builds `roadmap.md` prioritized by: Não sei > Preciso reforçar > review of Domino topics. (Not yet done — next natural step.)
3. User studies material-by-material. When an insight comes up in conversation, Claude scaffolds a file in `insights/`; the user writes the content themselves to retain it.
4. Incremental commits keep the repo as the running knowledge base — Claude commits after each meaningful addition (README/ementa/materiais/insights changes), using the repo's established commit style (imperative Portuguese summary line + body).

**Next action when resuming:** check current state of `ementa.md`, `insights/`, `app/doc.md`, and `infra/*/` before assuming the summary below is still accurate — this file is a snapshot, not a live view, and this project moves fast session to session.

---

## Hands-on data mesh exercise (started 2026-10-09)

Goal: simulate a small real data mesh on AWS to learn by doing, and to have a base for demystifying Feature Store/Model Registry concepts for the user's own EML team later. Full living design doc: `app/doc.md` (always re-read it first — it's the source of truth, this is a summary that will drift).

**Domains:** `crm` (table `sor_crm_customers`, partitioned `ano=/mes=`, new customer batch every 30 simulated days) and `payment` (table `sor_financial_transactions`, partitioned `ano=/mes=/dia=`, new transactions every simulated day).

**Architecture pivot 2026-10-10 — dropped EC2, split into 2 steps:** the original "EC2 ticker running continuously per domain" idea was abandoned (cost + complexity not worth it for a study project; also dropped Go entirely for this part). New split:
- **Step 1 (done):** `datagen/generate.py` — local Python script (`pyarrow` + `Faker`, venv in `datagen/.venv`, gitignored), zero AWS cost. Simulates day-by-day in a tight loop (no real-time wait, unlike the original "30s = 1 day" ticker idea): daily transactions, customer batch every 30 simulated days, `customer_id` on transactions drawn from already-generated customers for referential realism. Writes Parquet directly into Hive-style partitions (`ano=/mes=/dia=`) matching the Glue tables. Output directory default was later moved from `datagen/output/` to **`app/data-mesh/`** (2026-10-10, user's explicit request) — update `.gitignore` accordingly if you see `datagen/output/` mentioned anywhere old, that path is stale.
- **Step 2 (in progress):** upload the local Parquet to S3, make it queryable via Athena. As of 2026-10-10: `infra/data-mesh/` (buckets + Glue tables) is planned but **not yet applied** — the user stopped to review the plan before `apply`, then paused further to go learn Terraform fundamentals (see [[terraform_fundamentals_covered]]), then to build a Makefile and reorganize infra into layers. Pick up from: review+apply `infra/data-mesh`, then build the actual S3 upload mechanism (not yet designed — likely `aws s3 sync`), then `infra/athena` (scaffolded, not applied), then the IAM least-privilege tightening (planned, not yet built) before testing an end-to-end Athena query.

**Infra layout decided 2026-10-10 — split into independent layers, each its own Terraform root module/state** (not reusable modules yet — see [[terraform_fundamentals_covered]] for why modules are deferred until a 3rd repeating case shows up):
```
infra/
  data-mesh/   → s3.tf (bucket per domain, for_each) + glue.tf (shared database + 2 explicit tables, NOT for_each
                 because crm/payment partition schemas genuinely differ) + locals.tf/variables.tf/versions.tf/outputs.tf
  athena/      → query-results bucket (with 7-day lifecycle expiration) + aws_athena_workgroup, scaffolded not applied
  iam/         → planned, not yet built: least-privilege policy for the human IAM user (currently over-privileged,
                 see the IAM admin-group finding below)
  (future) feature-store/, model-registry/ slot in the same way
```
File-splitting convention adopted (see [[terraform_fundamentals_covered]] for the full reasoning): one `main.tf` per layer by default; only split into named files (`s3.tf`, `glue.tf`, ...) once a layer has genuinely distinct concerns or grows uncomfortably long. `infra/athena/` intentionally kept as a single `main.tf` (small, 3 resources) while `infra/data-mesh/` is split (bigger, two distinct concerns). The user asked directly whether this inconsistency was a mistake — it wasn't, it's deliberate and was explained.

**Makefile** (repo root, only runs from inside WSL): `MODULE` variable selects which `infra/<layer>` to target (default `data-mesh`) for `plan`/`apply`/`rollback` (`rollback` = `destroy`, Terraform has no real version-rollback). Added target `make datagen` (creates/reuses the venv, runs `generate.py`, flags passed via `ARGS="--days N ..."`).

**IAM finding 2026-10-10 — contradicts the least-privilege lesson taught earlier:** the IAM user `eml_carrer` (used for all Terraform/CLI work, profile `eml-carrer`) turned out to be a member of an IAM group called `admin` with **`AdministratorAccess`** attached — full unrestricted account access. Discovered by checking `aws iam list-attached-user-policies` (empty) → `list-groups-for-user` (group `admin`) → `list-attached-group-policies` (AdministratorAccess). User explicitly agreed (2026-10-10) to: remove `eml_carrer` from the `admin` group, and build a real least-privilege policy via `infra/iam/` scoped to exactly what this project uses (S3 CRUD + Glue CRUD + Athena query/workgroup actions, scoped by the `eml-carrer-*` naming convention already used everywhere). **Not yet done** — sequencing matters: do this LAST, only after `data-mesh`/`athena` are fully built and tested while still admin, otherwise risk locking out the ability to finish building them. Also note: day-to-day least-privilege and "bootstrap/break-glass" IAM-self-management access are different concerns — the planned policy won't necessarily let `eml_carrer` manage its own IAM permissions going forward; that's a deliberate, discussed trade-off, not an oversight.

## Infra operational facts learned (keep these — they cost real debugging time)

- Terraform **cannot run natively on this Windows machine** — Windows 11 Smart App Control blocks the unsigned `terraform-provider-aws` binary (confirmed via CodeIntegrity event log, policy requires "Enterprise signing level"). Fix adopted: run Terraform + AWS CLI (and Python, same native-extension risk) inside **WSL (Ubuntu)** instead — not a registry/security-settings workaround, just a different execution environment. Always run infra commands via `wsl -d Ubuntu -u root -- bash -lc "..."` (or interactively `wsl -d Ubuntu -u root`), never via native PowerShell/Git Bash on Windows. `make` also only works inside WSL (installed there 2026-10-09, not on native Windows).
- Windows path `C:\Users\Lunam\www\eml-carrer` = WSL path `/mnt/c/Users/Lunam/www/eml-carrer`.
- WSL users have separate `$HOME`/`~/.aws` per Linux user (`root` vs `luna`) — credentials configured under one aren't visible under the other. The working setup uses **root** inside WSL (`wsl -d Ubuntu -u root`, no password needed — WSL trusts the Windows account, not Linux sudo).
- AWS CLI profile `eml-carrer` is configured (under WSL root's `~/.aws`) using the IAM user `eml_carrer` (created 2026-10-09, replaced an earlier accidental use of AWS **root account** credentials via `aws login` browser session — that root session was revoked via `aws logout` on 2026-10-09, `default` profile now requires re-auth). All work uses the `eml-carrer` profile only. Terraform's `aws_profile` variable defaults to `"eml-carrer"` in every layer.
- First S3+Terraform smoke test (generic bucket + test.txt) was built, applied, then destroyed manually outside Terraform (via console/CLI), which desynced the state; state was wiped and started fresh. This is also the concrete example used later to teach why the state file is Terraform's only source of truth — see [[terraform_fundamentals_covered]].
- A disposable, zero-cost Terraform teaching sandbox existed at `infra/_sandbox/` (providers `random`+`local`, no AWS) on 2026-10-10 — fully deleted after the lesson, don't expect it to exist; recreate the same pattern if another fundamentals lesson is needed. Full breakdown of what was taught there: [[terraform_fundamentals_covered]].
