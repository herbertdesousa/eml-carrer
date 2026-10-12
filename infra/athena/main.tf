# Obrigatório: o Athena sempre materializa o resultado de toda query em S3
# antes de devolver — nunca retorna o resultado "direto".
resource "random_id" "results_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "query_results" {
  bucket = "eml-carrer-athena-results-${random_id.results_suffix.hex}"
}

# Sem isso, resultado de query acumula no bucket pra sempre.
resource "aws_s3_bucket_lifecycle_configuration" "query_results" {
  bucket = aws_s3_bucket.query_results.id

  rule {
    id     = "expire-old-results"
    status = "Enabled"

    filter {}

    expiration {
      days = var.query_results_expiration_days
    }
  }
}

# enforce_workgroup_configuration trava o destino do resultado, pra ninguém
# rodar query achando que vai usar outro bucket por engano.
resource "aws_athena_workgroup" "eml_carrer" {
  name = "eml-carrer-data-mesh"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = false

    result_configuration {
      output_location = "s3://${aws_s3_bucket.query_results.id}/"
    }
  }
}
