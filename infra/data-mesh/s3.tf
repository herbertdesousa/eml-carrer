# Nomes de bucket S3 são únicos globalmente na AWS, não só na conta — por
# isso o sufixo aleatório.
resource "random_id" "bucket_suffix" {
  for_each    = local.domains
  byte_length = 4
}

resource "aws_s3_bucket" "domain" {
  for_each = local.domains
  bucket   = "${var.bucket_name_prefix}-${each.key}-${random_id.bucket_suffix[each.key].hex}"

  tags = {
    Domain = each.key
  }
}
