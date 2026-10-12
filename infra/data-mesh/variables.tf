variable "aws_region" {
  description = "Região AWS onde a infra do data mesh será criada"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name_prefix" {
  description = "Prefixo dos buckets S3 (um por domínio; sufixo aleatório garante nome único globalmente)"
  type        = string
  default     = "eml-carrer"
}

variable "aws_profile" {
  description = "Named profile do ~/.aws/credentials usado pelo terraform (nunca depender do profile default implícito)"
  type        = string
  default     = "eml-carrer"
}
