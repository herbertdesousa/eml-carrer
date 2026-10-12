output "query_results_bucket" {
  description = "Bucket onde o Athena grava o resultado das queries"
  value       = aws_s3_bucket.query_results.id
}

output "query_results_bucket_arn" {
  description = "ARN do bucket de resultados (usado pela policy IAM em infra/iam)"
  value       = aws_s3_bucket.query_results.arn
}

output "workgroup_name" {
  description = "Nome do workgroup Athena a usar nas queries (aws athena start-query-execution --work-group ...)"
  value       = aws_athena_workgroup.eml_carrer.name
}
