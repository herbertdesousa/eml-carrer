# Catálogo compartilhado pelos dois domínios — é só metadado, quem é dono do
# dado em si é o bucket de cada domínio (s3.tf).
resource "aws_glue_catalog_database" "data_mesh" {
  name = "eml_carrer_data_mesh"
}

# Partition projection em vez de Glue Crawler: evita o custo por execução do
# crawler e não depende de rodar algo manual quando aparece partição nova.
resource "aws_glue_catalog_table" "crm_customers" {
  name          = "sor_crm_customers"
  database_name = aws_glue_catalog_database.data_mesh.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification"            = "parquet"
    "projection.enabled"        = "true"
    "projection.ano.type"       = "integer"
    "projection.ano.range"      = "2024,2030"
    "projection.mes.type"       = "integer"
    "projection.mes.range"      = "1,12"
    "projection.mes.digits"     = "2"
    "storage.location.template" = "s3://${aws_s3_bucket.domain["crm"].bucket}/sor_crm_customers/ano=$${ano}/mes=$${mes}/"
  }

  partition_keys {
    name = "ano"
    type = "string"
  }
  partition_keys {
    name = "mes"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.domain["crm"].bucket}/sor_crm_customers/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "customer_id"
      type = "string"
    }
    columns {
      name = "name"
      type = "string"
    }
    columns {
      name = "created_at"
      type = "timestamp"
    }
  }
}

resource "aws_glue_catalog_table" "financial_transactions" {
  name          = "sor_financial_transactions"
  database_name = aws_glue_catalog_database.data_mesh.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification"            = "parquet"
    "projection.enabled"        = "true"
    "projection.ano.type"       = "integer"
    "projection.ano.range"      = "2024,2030"
    "projection.mes.type"       = "integer"
    "projection.mes.range"      = "1,12"
    "projection.mes.digits"     = "2"
    "projection.dia.type"       = "integer"
    "projection.dia.range"      = "1,31"
    "projection.dia.digits"     = "2"
    "storage.location.template" = "s3://${aws_s3_bucket.domain["payment"].bucket}/sor_financial_transactions/ano=$${ano}/mes=$${mes}/dia=$${dia}/"
  }

  partition_keys {
    name = "ano"
    type = "string"
  }
  partition_keys {
    name = "mes"
    type = "string"
  }
  partition_keys {
    name = "dia"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.domain["payment"].bucket}/sor_financial_transactions/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "transaction_id"
      type = "string"
    }
    columns {
      name = "customer_id"
      type = "string"
    }
    columns {
      name = "amount"
      type = "double"
    }
    columns {
      name = "created_at"
      type = "timestamp"
    }
  }
}
