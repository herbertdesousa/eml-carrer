# Data Mesh — Documentação do Exercício

## Objetivo

Simular um data mesh pequeno e real na AWS para aprender na prática: cada área de negócio (domínio) é dona dos seus dados e do seu bucket — nada centralizado. Serve de base para destrinchar, no dia a dia do time de EML, como Feature Store/Model Registry se conectam a essa camada (SoR).

**Princípio inegociável do projeto:** é um ambiente de teste. Sempre subir o mínimo necessário, testar, e **desligar/destruir os recursos ao terminar** para não gerar custo. `make rollback` (= `terraform destroy`) é parte do fluxo normal, não uma emergência.

---

## Domínios (áreas) e suas tabelas SoR

### `crm`
- Tabela: `sor_crm_customers`
- Partição: `ano=YYYY/mes=MM/`
- Geração: lote de clientes novos a cada **30 dias simulados**

### `payment`
- Tabela: `sor_financial_transactions`
- Partição: `ano=YYYY/mes=MM/dia=DD/`
- Geração: transações novas em **todo dia simulado**

A diferença de granularidade de partição reflete o volume/cadência real de cada tipo de dado — mesmo raciocínio usado pra decidir partição em qualquer pipeline de dados de verdade.

---

## Arquitetura (3 passos)

```
Passo 1 (feito)                 Passo 2 (parte feita)              Passo 3 (a fazer)
──────────────────               ──────────────────                 ──────────────────
datagen/generate.py        →     make sync (aws s3 sync)      →     Athena (SQL ad-hoc)
gera Parquet particionado        copia app/data-mesh/ pros          lê via infra/athena/
em app/data-mesh/                buckets de infra/data-mesh/        (workgroup + bucket
                                  (ainda não aplicado)                de resultado)
```

### Passo 1 — gerador de massa de dados (`datagen/`)

- Script Python (`datagen/generate.py`), roda local, sem nenhuma infra/custo AWS.
- Libs: `pyarrow` (escreve Parquet nativo) + `Faker` (dados falsos realistas).
- Simula dia a dia (sem esperar tempo real): a cada dia simulado gera transações; a cada 30 dias simulados gera um novo lote de clientes — `customer_id` das transações é sempre sorteado dos clientes já existentes, pra manter a relação realista entre as duas tabelas.
- Saída em `app/data-mesh/` (já no layout de partição Hive que o Glue espera).
- Rodar: `make datagen ARGS="--days 90 --start-date 2026-01-01"` (flags disponíveis: `--customers-per-batch`, `--customer-batch-interval-days`, `--tx-per-day-min/max`, `--output-dir`).

### Passo 2 — subir pro S3

- `make sync`: lê `bucket_names` do output do `infra/data-mesh` (os nomes têm sufixo aleatório, não dá pra hardcodar) e roda `aws s3 sync` de cada pasta de domínio pro bucket correspondente.
- Deliberadamente **fora do Terraform** — subir dado não é a mesma coisa que gerenciar infra, e `aws s3 sync` já é idempotente (só copia o que é novo ou mudou).
- **Pré-requisito:** `infra/data-mesh` precisa estar `apply`ado antes (os buckets precisam existir e o output precisa estar disponível). Ainda não foi aplicado.

### Passo 3 — consultar via Athena

- `infra/athena/`: bucket de resultado de query (lifecycle de 7 dias, pra não acumular custo) + `aws_athena_workgroup`.
- Glue Data Catalog (schema + partition projection, sem Crawler) já definido em `infra/data-mesh/glue.tf` — não depende do Athena pra existir, só precisa que os dados já estejam no S3 pra as queries retornarem algo.
- Ainda não aplicado, nem testada nenhuma query de ponta a ponta.

---

## Estrutura do `infra/` (layers independentes)

```
infra/
  data-mesh/   → bucket S3 por domínio + Glue database/tabelas (for_each pro bucket, blocos
                 explícitos pra cada tabela Glue — schemas de partição diferentes entre
                 crm/payment, não compensa generalizar). Plan revisado, ainda não aplicado.
  athena/      → bucket de resultado + workgroup. Escrito, ainda não aplicado.
  iam/         → ainda não existe. Vai conter a policy de least-privilege pro usuário
                 eml_carrer (ver achado abaixo) — só depois que data-mesh/athena estiverem
                 aplicados e testados, pra não perder permissão no meio do caminho.
```

Cada pasta é um root module Terraform com seu próprio state — destruir/recriar um layer nunca arrisca o outro. `Makefile` usa `MODULE=<layer>` pra escolher onde `plan`/`apply`/`rollback` atuam (default `data-mesh`).

**Achado de segurança (2026-10-10):** o usuário IAM `eml_carrer` está no grupo `admin` com `AdministratorAccess` — acesso total, contradizendo a lição de least-privilege do início do projeto. Corrigir **só no final**, depois que toda a infra estiver aplicada e testada (ver `infra/iam/` acima).

---

## Status atual

- [x] **Passo 1**: `datagen/generate.py` gerando Parquet em `app/data-mesh/` — testado (35 dias, 100 clientes, 3884 transações, partições corretas).
- [x] `Makefile`: `plan` / `apply` / `rollback` (por `MODULE`), `datagen`, `sync`.
- [x] `infra/data-mesh/` e `infra/athena/` escritos e validados (`terraform validate`/`plan` ok) — **nenhum dos dois aplicado ainda**.
- [ ] Aplicar `infra/data-mesh` (buckets + Glue).
- [ ] Rodar `make sync` e confirmar os Parquet chegando no S3.
- [ ] Aplicar `infra/athena` e rodar uma query de teste nas duas tabelas.
- [ ] `infra/iam/`: tirar `eml_carrer` do grupo `admin`, aplicar policy least-privilege (**depois** dos itens acima).

---

## Lembrete de custo

Sempre que terminar uma sessão de testes com infra aplicada: `make rollback MODULE=<layer>`. O gerador de dados (`datagen/`) e o `make sync` não têm custo de compute — só o que já existe de armazenamento no S3 (pouquíssimo, nesse volume de teste).
