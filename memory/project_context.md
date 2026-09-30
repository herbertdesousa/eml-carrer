---
name: eml-carrer-project
description: Structure, purpose, and workflow of the eml-carrer git repo — study base for the EML exam
---

Repo: `C:\MyStuffs\eml-carrer`, git-initialized locally.

**Purpose:** versioned personal knowledge base to study for the bank's EML (Engenharia de Machine Learning) exam, built incrementally in collaboration with Claude across sessions. See [user_profile.md](user_profile.md) for who this is for and why.

**Structure:**
- `README.md` — context: user's profile, the team's role (self-service ML deployment platforms, framework homologation, data scientist enablement, architecture/cloud/security/governance integration), and the repo's workflow.
- `ementa.md` — the exam syllabus, one section per topic, each with **3 independent checkboxes**: `Domino` / `Preciso reforçar` / `Não sei`. Filled in by the user on 2026-09-28.
- `materiais.md` — the exam's official supporting materials, organized by theme with read-status checkboxes.
- `insights/` — dated insight notes. **Content is written by the user, not Claude** — see [feedback_insight_authorship.md](feedback_insight_authorship.md). Claude only scaffolds the file (title, "De onde veio" context, empty headers) from `insights/_template.md`.
- `memory/` — this folder: versioned copy of Claude's project memory, kept in sync with the local `~/.claude/.../memory/` store.
- `add-ons.md` — subjects outside the official ementa but conceptually load-bearing for it (created 2026-09-29). First batch: Data Lake, Data Warehouse, Data Mesh, named conceptually as "paradigmas/arquiteturas de armazenamento e organização de dados" (data storage & organization architectures) — all answer "where/how does org data live and get consumed", trading off centralization-vs-domain-ownership and schema-on-read-vs-write. Same 3-checkbox self-assessment convention as `ementa.md`. User has since edited the file structure themselves (consolidated the three topics under one combined checklist) — trust the live file over this description.
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

**Next action when resuming:** check current state of `ementa.md`, `insights/`, and whether `roadmap.md` exists yet before assuming the summary above is still accurate — this file is a snapshot, not a live view.
