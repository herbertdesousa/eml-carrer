# Roda sempre de dentro do WSL (terraform/aws-cli/python só funcionam lá
# nesta máquina — Smart App Control do Windows bloqueia os binários nativos).
#
# infra/ tem um "layer" por pasta (data-mesh, athena, iam, ...), cada um com
# seu próprio state. MODULE escolhe qual: `make plan MODULE=athena`.
MODULE ?= data-mesh
INFRA_DIR := infra/$(MODULE)
DATA_MESH_DIR := infra/data-mesh
DATAGEN_DIR := datagen
AWS_PROFILE ?= eml-carrer

.PHONY: plan apply rollback destroy datagen sync

plan:
	cd $(INFRA_DIR) && terraform plan -out=tfplan

apply:
	cd $(INFRA_DIR) && terraform apply tfplan

# "rollback" aqui = desfazer o último apply, destruindo o que o terraform criou.
# Terraform não tem rollback de verdade (não existe histórico de versões como num banco);
# o equivalente é destroy, baseado no state atual.
rollback destroy:
	cd $(INFRA_DIR) && terraform destroy

# Gera a massa de dados (Parquet) em app/data-mesh/. Cria o venv na primeira
# vez; nas próximas só reaproveita. Passar flags extras com ARGS, ex:
#   make datagen ARGS="--days 180 --start-date 2026-01-01"
datagen:
	cd $(DATAGEN_DIR) && \
		(test -d .venv || python3 -m venv .venv) && \
		.venv/bin/pip install -q -r requirements.txt && \
		.venv/bin/python generate.py $(ARGS)

# Copia o Parquet local (app/data-mesh/) pro bucket de cada domínio. Não é
# gerenciado pelo Terraform de propósito — subir dado não é "infra", e
# aws s3 sync já é idempotente (só copia o que é novo/mudou). Os nomes dos
# buckets saem direto do output do infra/data-mesh (tem sufixo aleatório,
# não dá pra hardcodar).
sync:
	@CRM_BUCKET=$$(cd $(DATA_MESH_DIR) && terraform output -json bucket_names | jq -r '.crm'); \
	PAYMENT_BUCKET=$$(cd $(DATA_MESH_DIR) && terraform output -json bucket_names | jq -r '.payment'); \
	echo "crm     -> s3://$$CRM_BUCKET/sor_crm_customers"; \
	aws s3 sync app/data-mesh/sor_crm_customers "s3://$$CRM_BUCKET/sor_crm_customers" --profile $(AWS_PROFILE); \
	echo "payment -> s3://$$PAYMENT_BUCKET/sor_financial_transactions"; \
	aws s3 sync app/data-mesh/sor_financial_transactions "s3://$$PAYMENT_BUCKET/sor_financial_transactions" --profile $(AWS_PROFILE)
