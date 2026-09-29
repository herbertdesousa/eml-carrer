# Arquitetura real do meu banco: SoR → SoT/Spec → Feature Store (books) → API

**De onde veio:** reflexão sobre o fluxo de dados real onde trabalho, comparando com os conceitos de time (ED/CD/EA/EML) do insight [[2026-09-28-taxonomia-times-de-dados]].

**O fluxo descrito:**
1. Times transacionais publicam **SoR** (S3 + Glue Catalog).
2. Time de **ED** consome SoR, faz ETL, gera **SoT** (ou às vezes **Spec**).
3. Time de **CD** cria modelos (a partir de Spec) ou books de variáveis (direto do SoR).
4. Time de **EML** constrói a plataforma de modelos e books, que cai numa camada fast (DynamoDB) e é entregue via API Golang.

## O que aprendi

**"Books" = Feature Store, mas com precisão:** uma Feature Store de verdade tem duas camadas — offline/batch (para treino, geralmente lake/warehouse) e online/serving (baixa latência, key-value). O que a plataforma de EML descrita opera é a **camada online** de uma feature store. Se a mesma plataforma também serve modelos, ela acumula **Feature Store + Model Serving** — duas responsabilidades que arquiteturas de referência (Uber Michelangelo, Tecton) tratam como distintas, mesmo coexistindo fisicamente.

**Sobreposição com ED não é falha, é padrão de mercado:** feature engineering frequentemente exige conhecimento de ML (agregação por janela, correção point-in-time, granularidade por entidade de inferência) que não é natural para ED. Por isso arquiteturas de referência colocam a Feature Store deliberadamente sob o time de ML/plataforma de ML, não sob Engenharia de Dados. O risco real não é território, é **governança**: calcular books direto do SoR (pulando o SoT) pode gerar duas fontes de verdade divergentes se ED transformar o mesmo dado bruto para outro fim — vale alinhamento de contrato/ownership de definição, não hierarquia.

**Nome da arquitetura:** não existe um nome único de mercado que cubra tudo, mas é a combinação de dois padrões conhecidos:
- **Medallion architecture** (Databricks): Bronze/Silver/Gold ≈ SoR/SoT/Spec.
- **Lambda architecture aplicada a features**: camada batch (offline store) + camada de serving de baixa latência (online store) — exatamente o desenho de referência de Feast/Tecton.
- Se cada domínio transacional é dono e publica seu próprio SoR, isso também ecoa princípios de **Data Mesh** (dado como produto, domínio dono da publicação), mesmo sem usar esse nome internamente.

**SoR, SoT, Spec — são conceitos reais?**
- **SoR (System of Record)** — termo padrão de mercado: sistema de origem autoritativo onde o dado nasce.
- **SoT (Source/System of Truth)** — também padrão, com nuance: alguns tratam como sinônimo de SoR, outros (como aqui) distinguem SoR (bruto) de SoT (reconciliado/conformado) — paralelo direto com a camada Silver ou "conformed data" do Kimball.
- **Spec** — termo menos universal, provavelmente nomenclatura própria do banco. Paralelos de mercado: **Data Product** (Data Mesh), **Data Mart** (Kimball), ou **Data Contract** (schema/contrato formal produtor-consumidor — tema atual em alta). "Spec" parece ser essencialmente um Data Contract aplicado.

**Mapeamento para a ementa:**

| Conceito da arquitetura | Tópico da ementa |
|---|---|
| SoR (S3 + Glue Catalog) | Arquitetura de Nuvem, AWS, Big Data |
| ED: SoR → SoT (ETL) | Engenharia/Ingestão de Dados, Modelagem de dados |
| CD: modelos a partir de Spec/SoR | Aprendizagem de Máquina, Feature Engineering |
| Books/variáveis | Feature Engineering, Feature Store |
| Camada fast (Dynamo) + API Golang | Feature Store, Desenho de solução para MLOps, Conceitos de Aplicação Web |
| Modelos servidos pela plataforma | Model Registry (vale investigar se existe registry formal antes do serving), CI/CD para ML |

**Desmistificar para o time?** Sim, dois pontos:
1. Deixar explícito que "acumular papel de ED" ao calcular books direto do SoR é um padrão de mercado esperado para times de ML Platform/EML, não uma invasão — mas exige contrato de definição com ED para não divergir do SoT.
2. Vale nomear explicitamente para o time que a plataforma atual acumula Feature Store (online) + Model Serving — dois conceitos que a indústria trata separado, o que ajuda a comunicar escopo/responsabilidade pra outros times.
