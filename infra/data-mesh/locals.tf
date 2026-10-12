# A tabela Glue de cada domínio fica em glue.tf como bloco explícito (não
# for_each) porque o esquema de partição difere de verdade entre eles.
locals {
  domains = toset(["crm", "payment"])
}
