# Add-ons — Assuntos além da ementa

A ementa cobra os tópicos na prática, mas alguns assuntos têm profundidade conceitual própria que vale estudar à parte — geralmente porque aparecem como pressuposto em outros temas (ex: Feature Store pressupõe entender Data Lake/Warehouse) ou porque são recorrentes em discussão de arquitetura no meu time.

Mesma convenção da [ementa.md](ementa.md): marque **um** status por tópico.

---

### Data Mesh, Data Warehouse, Data Lake

- [ ] [Martin Fowler — How to break a Monolithic Data Lake / Data Mesh](https://martinfowler.com/articles/data-monolith-to-mesh.html)
- [ ] [Martin Fowler — DataLake](https://martinfowler.com/bliki/DataLake.html)
- [ ] Domino
- [ ] Preciso reforçar
- [ ] Não sei

---

### AWS — boas práticas (IAM, CLI, segurança de credenciais)

Surgiu ao preparar a infra de teste do data mesh em `infra/` — antes de rodar `aws configure`, quero entender o jeito certo de fazer (IAM, least privilege, roles vs. usuários, MFA, SSO) em vez de só sair criando access keys.

- [ ] Domino
- [ ] Preciso reforçar
- [ ] Não sei

### Terraform — uso idiomático

Infra as Code já está na ementa oficial como "Preciso reforçar"; Terraform especificamente é a ferramenta usada no exercício prático de data mesh (`infra/`) e quero dominar o padrão de mercado (estrutura de módulos, state remoto, variáveis/outputs, versionamento de providers).

- [ ] Domino
- [ ] Preciso reforçar
- [ ] Não sei

---

Ao concluir a leitura de um tópico, criar (ou pedir ao Claude para criar o esqueleto de) uma nota em [insights/](insights/) — ver convenção de autoria em [insights/README.md](insights/README.md).
