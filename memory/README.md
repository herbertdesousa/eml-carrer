# Memória do Claude sobre este projeto

Esta pasta é a cópia **versionada** do contexto que o Claude mantém sobre este projeto (perfil, feedback de como trabalhar, estado do projeto). Fica dentro do repo — e não só na memória local do Claude Code (`~/.claude/.../memory/`) — porque:

- viaja com o repo se ele for clonado em outra máquina;
- fica visível/editável por mim como qualquer outro arquivo;
- não depende de nenhuma configuração local do Claude Code para existir.

O Claude deve manter esta pasta e a memória local em sincronia: sempre que salvar algo relevante sobre este projeto na memória local, replicar aqui (e vice-versa, se eu editar aqui diretamente).

- [user_profile.md](user_profile.md) — quem sou, meu objetivo com o estudo.
- [project_context.md](project_context.md) — estrutura e fluxo de trabalho deste repo.
- [feedback_insight_authorship.md](feedback_insight_authorship.md) — como o Claude deve (não) escrever os insights.
- [domain_knowledge_covered.md](domain_knowledge_covered.md) — resumo das explicações conceituais já dadas (Feature Store, Model Registry, Lambda/Kappa, SoR/SoT/Spec, etc.), pra não re-explicar do zero.
- [terraform_fundamentals_covered.md](terraform_fundamentals_covered.md) — conceitos de Terraform (providers, state, plan, módulos) já ensinados via o sandbox descartável, pra não re-explicar do zero.
- [feature_store_exercise.md](feature_store_exercise.md) — plano do exercício simples de feature store (`customer_total_amount`): arquitetura, decisões de nome e as dúvidas conceituais (SoT vs feature, book de variáveis, point-in-time) resolvidas antes de construir.
