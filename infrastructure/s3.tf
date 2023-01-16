resource "aws_s3_bucket" "appointment_artefact_bucket" {
  bucket = "appointment-artefact-bucket"
}
resource "aws_s3_bucket_acl" "appointment_artefact_bucket_acl" {
  bucket = aws_s3_bucket.appointment_artefact_bucket.id
  acl    = "private"
}
resource "aws_s3_bucket_versioning" "appointment_artefact_bucket_versioning" {
  bucket = aws_s3_bucket.appointment_artefact_bucket.id
  versioning_configuration {
    status = "Enabled"
}
}