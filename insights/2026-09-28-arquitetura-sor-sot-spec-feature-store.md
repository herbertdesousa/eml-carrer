# Arquitetura real do meu banco: SoR → SoT/Spec → Feature Store (books) → API

**De onde veio:** reflexão sobre o fluxo de dados real onde trabalho, comparando com os conceitos de time (ED/CD/EA/EML) do insight [[2026-09-28-taxonomia-times-de-dados]].

**O fluxo descrito:**

1. Times transacionais publicam **SoR** (S3 + Glue Catalog).
2. Time de **ED** consome SoR, faz ETL, gera **SoT** (ou às vezes **Spec**).
3. Time de **CD** cria modelos (a partir de Spec) ou books de variáveis (direto do SoR).
4. Time de **EML** constrói a plataforma de modelos e books, que cai numa camada fast (DynamoDB) e é entregue via API Golang.

## O que aprendi

- Feature store há multiplas partes:
  . Ingestão: Offline/batch com books ou Online/Streaming com eventos
  . Online/serving: Dynamo + API Golang.
