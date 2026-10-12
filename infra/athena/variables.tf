variable "aws_region" {
  description = "Região AWS (deve bater com a do infra/data-mesh)"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Named profile do ~/.aws/credentials usado pelo terraform"
  type        = string
  default     = "eml-carrer"
}

variable "query_results_expiration_days" {
  description = "Dias até os resultados de query no S3 serem apagados automaticamente (controle de custo)"
  type        = number
  default     = 7
}
