---
name: domain-knowledge-covered
description: "Conceptual ML platform/data-architecture explanations already given to the user — avoid re-deriving from scratch, build on top instead"
metadata:
  node_type: memory
  originSessionId: 73f5b50a-4f93-41b7-a13e-dc08341d3a9f
  modified: 2026-10-10T17:13:34.379Z
---

Running log of the conceptual explanations already covered in conversation, mapped to the user's real architecture (see [project_context.md](project_context.md) for the architecture diagram: Jornadas → SoR (Data Mesh, medallion) / Kafka → ED (SoT/Spec) + CD (modelos/books) → EML (Model Registry + Feature Store: Book registry, Online Ingestor, Serving layer Dynamo/API)).

**Feature Store anatomy** (Feast/Tecton/Michelangelo reference architecture):
- Feature/Book Registry — metadata catalog (definitions, owner, schema, version, lineage, SLA) — distinct from where values live.
- Compute/transformation engine — batch and/or streaming.
- Offline store — historical feature values for training.
- Online store — low-latency current values for inference (their Dynamo).
- Serving API — exposes values to consumers (their Golang API).
- Noted gap: their platform seems to lack a visible offline store — likely CD trains directly off SoT/Spec instead, not through the feature store. Flagged as an open question, not confirmed.

**Model Registry components** (MLflow/SageMaker style): model catalog, versioning (immutable per training run), artifact reference (not the blob itself), evaluation metrics per version, lineage (training code, dataset/books used — ties to Book Registry), model signature/schema (expected input features + output), stage/lifecycle management (staging/prod/archived) with promotion gate, governance/audit trail, deployment metadata.

**Model Registry vs Feature Store:** sibling umbrellas under MLOps platform, not nested — one catalogs data (features), the other catalogs models. They connect via lineage: a registered model version references which features/books it consumes.

**Batch + streaming (NRT) feature ingestion:** adding Kafka as a second ingestion path into the same online store is the classic **Lambda Architecture** (batch layer + speed layer + shared serving layer) applied to features — not a different architecture, just the speed-layer half being made explicit. If batch is ever fully replaced by stream replay, that becomes **Kappa Architecture**. Flagged risk: training-serving skew if batch vs. streaming feature computation logic isn't provably equivalent.

**SoR/SoT/Spec mapped to industry terms:**
- SoR (System of Record) = standard term, origin/authoritative system ≈ medallion "Bronze".
- SoT (Source/System of Truth) = standard but with local nuance (reconciled/conformed) ≈ medallion "Silver" / Kimball "conformed data".
- Spec = less universal, bank-specific naming; closest market parallels are **Data Product** (Data Mesh), **Data Mart** (Kimball), or **Data Contract** (schema/contract between producer and consumer).
- EML/CD building features straight from SoR (bypassing ED's SoT) is a recognized industry pattern (feature engineering needs ML-specific logic ED doesn't own), not a turf violation — the real risk is governance of duplicated transform logic diverging from SoT's definition.

**Data Lake / Data Warehouse / Data Mesh family:** named conceptually as "paradigmas/arquiteturas de armazenamento e organização de dados" — all answer where/how org data lives and gets consumed, trading off centralization-vs-domain-ownership and schema-on-read-vs-write. This is the umbrella name used in `add-ons.md`.

**Team taxonomy (ED/CD/EA/EML) and others:** see the insight note `insights/2026-09-28-taxonomia-times-de-dados.md` for the full breakdown of team capabilities and how CD4ML's Data+Model+Code maps onto them.

**Terraform fundamentals (IaC tooling, not ML/data domain, but same "don't re-derive" principle):** see [[terraform_fundamentals_covered]] for the full breakdown (providers, state, plan diffs, modules) taught via a disposable sandbox on 2026-10-10.
