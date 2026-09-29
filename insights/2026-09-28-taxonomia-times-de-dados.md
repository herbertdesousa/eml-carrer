# Taxonomia de times no contexto de dados (ED, CD, EA, EML e outros)

**De onde veio:** dúvida disparada pela imagem "Data + Model + Code" do artigo [CD4ML — Martin Fowler](https://martinfowler.com/articles/cd4ml.html).

**Pergunta original:** além de ED (Engenharia de Dados), CD (Ciência de Dados), EA (Engenharia de Analytics) e EML (Engenharia de Machine Learning), existem outros times? Como se relacionam conceitualmente? É uma distinção universal ou específica de onde eu trabalho?

## O que aprendi

**Outros times que aparecem em orgs maduras (além dos 4 citados):**
- Data Platform / Data Infrastructure — infra genérica (cluster, storage, processamento distribuído) que ED consome; às vezes fundido com ED.
- Data Governance / Qualidade de Dados — catalogação, linhagem, compliance (LGPD). Em bancos costuma ser time próprio por regulação.
- BI / Business Intelligence — dashboards/relatórios; hoje frequentemente absorvido por EA.
- MLOps / ML Platform — infraestrutura genérica de ML que um time de EML consome (vs. EML resolvendo o problema de um time de negócio específico). No meu contexto atual, o time de EML parece acumular os dois papéis.
- Decision Science / Business Analytics — análise para decisão de negócio, sem necessariamente produtizar modelo (mais leve que CD).
- Data Architecture — padrões de modelagem/integração em nível corporativo.
- AI Research — só existe em orgs que fazem pesquisa aplicada de verdade; incomum em bancos tradicionais.

**Universal vs. específico do local:**
As *funções* (ingerir/armazenar → transformar em consumível → experimentar/modelar → produtizar) são praticamente universais em qualquer organização data-mature — é o fluxo natural do dado até virar valor. Mas **como essas funções viram times, com que nome e onde ficam as fronteiras é decisão organizacional**, influenciada por tamanho da empresa, maturidade regulatória (bancos isolam Governança por compliance) e até modismos de mercado ("Analytics Engineering" como papel formal só pegou tração por volta de 2020, puxado pela comunidade dbt/Locally Optimistic — antes disso a função existia dissolvida dentro de ED ou CD).

**Capacidades teóricas de cada time (tabela resumo):**

| Time | Pergunta que resolve | Capacidades típicas |
|---|---|---|
| ED | Como o dado chega confiável e disponível? | Ingestão/ETL-ELT, orquestração, Big Data, modelagem bruta/staging, qualidade e SLA, storage |
| EA | Como transformo dado bruto em algo que o negócio confia? | Transformação semântica (estilo dbt), camada de métricas, testes de dados, habilita BI |
| CD | Que padrão/previsão existe nesse dado? | Análise exploratória, estatística, feature engineering, treino de modelos, experimentação |
| EML | Como esse modelo roda em produção de forma confiável e escalável? | CI/CD para ML, Model Registry, Feature Store, serving/monitoramento, IaC, integração com arquitetura/segurança/cloud |

**Ponte com CD4ML:** o framework Data + Model + Code do artigo mapeia quase 1:1 nesses times — Data (schema/sampling/volume) é domínio de ED, Model (algoritmos/treino/experimentos) é domínio de CD, Code (necessidades de negócio/bugfix/configuração) é domínio de EML. O argumento central do CD4ML — entrega contínua conjunta das três dimensões — é essencialmente a razão de existir do EML: sem ele, CD produz modelo mas ele não sai do notebook de forma confiável e reprodutível.

**Relação com a ementa:** reforça [Engenharia/Ingestão de Dados](../ementa.md), [Desenho de solução para MLOps](../ementa.md) e [Aprendizagem de Máquina](../ementa.md) (todas marcadas como não domino/preciso reforçar).

**Desmistificar para o time?** Sim — vale uma conversa curta com o time de EML sobre onde termina a responsabilidade de EML vs. CD vs. ML Platform, principalmente porque no meu contexto o time parece acumular papel de EML + ML Platform, o que pode gerar expectativa desalinhada com outros times.
