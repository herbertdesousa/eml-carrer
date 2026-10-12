---
name: feature-store-exercise
description: "Simple feature store exercise planned on top of the data mesh (crm/payment) — architecture, naming decisions, and the conceptual questions resolved before building"
metadata:
  type: project
  node_type: memory
  originSessionId: 73f5b50a-4f93-41b7-a13e-dc08341d3a9f
  modified: 2026-10-12
---

Next hands-on exercise after the data mesh ([[project_context]]), planned 2026-10-12, **not yet built** — discussion/design only so far, no code/infra written.

## Goal

Cross the two existing SoR tables (`sor_crm_customers`, `sor_financial_transactions`) to compute one feature: **total amount transacted by a customer over a period**. Purpose: learn feature engineering + a minimal feature store hands-on, and build material to demystify these concepts for the user's EML team later.

## Consolidated architecture (agreed 2026-10-12)

```
SoR (s3: crm + payment, already applied via infra/data-mesh)
    ↓
Glue job "customer_total_amount" (reads sor_crm_customers + sor_financial_transactions)
    ↓
Feature Store (s3): bucket/customer_total_amount/ano=YYYY/mes=MM/part-*.parquet
```

- **No Step Functions** — a single Glue job with one input→output, no branching/retry/cross-service orchestration needed yet. Step Functions becomes relevant only once there are 2+ chained jobs across services, or conditional/retry logic is actually needed.
- **No intermediate SoT layer** — went straight SoR → Feature Store. A SoT layer would only be justified if some *other* generic (non-ML) consumer needed this same aggregated value; here the feature is the final product.
- **Partitioned by period (`ano=/mes=`), not by customer** — this was the key correction from the user's original idea (`bucket/{ingestor}/<customer-id>.parquet`, one overwritten file per customer). See point-in-time correctness below for why.

## Naming decisions

- Rejected name: "User amount Ingestor" — "ingestor" already means bringing raw data in from a source system (that's the SoR step, done). This job **transforms/aggregates**, so it's a **feature engineering job**, not an ingestor. Calling it an ingestor mislabels the layer.
- Adopted: name the job/output after the *feature* it produces (e.g. `customer_total_amount`), not after a generic mechanism word.

## Conceptual questions resolved (useful for demystifying later)

**SoT vs. Feature — not the same thing.** SoT = clean/curated but still generic data, usable by any consumer for any purpose. A Feature = data shaped specifically for ML consumption, with point-in-time correctness and (usually) registered schema/versioning. "Spec" is not a standard industry term — it was the user's own naming, closest real parallels are Data Product / Data Mart / Data Contract (already captured in [[domain_knowledge_covered]]).

**"Book de variáveis" = feature registry, not the feature store itself.** Classic Brazilian banking/credit-risk term. Maps to the **registry/catalog** half of a feature store (name, formula, source tables, owner, update frequency, business meaning — metadata about the variable), historically implemented in banks as documented tables/views (SAS/SQL) for audit/regulatory traceability (Bacen can ask "why did the model deny this loan"), predating formal feature-store tooling. The **feature store (offline/online)** is the other half — where the actual computed *values* live. Mapping: book de variáveis (definition) → feature engineering job (computes per the definition) → feature store (stores the values).

**Point-in-time correctness.** The core bug in the user's original one-file-per-customer design: every training row would read the *current* (today's) accumulated value regardless of the row's actual reference date, leaking future information into training (model looks great in test, fails in production because production never has access to the future). Fix: partition/version feature values by the period they were computed for, so you can always ask "what was this feature's value as of date X" and get the correct historical snapshot — never the latest. Mature feature stores (Feast/Tecton/SageMaker FS) automate this via a "point-in-time join" API; here it's manual via `ano=/mes=` partitioning.

**Other offline-feature-store capabilities intentionally NOT built here** (mapped for future reference, not planned for this exercise):
1. Online store / low-latency serving (Redis/DynamoDB) — only the offline/batch half is being built.
2. Training-serving consistency (same formula in batch vs. real-time paths).
3. TTL/freshness tracking on feature values.
4. Automated backfill when a feature's definition changes.
5. Feature versioning (which model version used which feature formula).
6. Drift monitoring.
7. Cross-team discovery/catalog search (ties back to the book de variáveis / registry concept).

## Status

Design-only as of 2026-10-12. Not yet built: `infra/feature-store/` layer, the Glue job itself, or a `book.md`-style definition doc for the feature. [[project_context]]'s "future" layer note (`feature-store/`, `model-registry/`) anticipated this.
