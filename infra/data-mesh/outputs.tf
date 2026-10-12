output "bucket_names" {
  description = "Nome do bucket S3 de cada domínio"
  value       = { for k, b in aws_s3_bucket.domain : k => b.id }
}

output "bucket_arns" {
  description = "ARN do bucket S3 de cada domínio (usado pela policy IAM em infra/iam)"
  value       = { for k, b in aws_s3_bucket.domain : k => b.arn }
}

output "glue_database" {
  description = "Nome do database Glue onde as tabelas do mesh ficam catalogadas"
  value       = aws_glue_catalog_database.data_mesh.name
}

