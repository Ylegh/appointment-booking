resource "aws_dynamodb_table" "appointment_table" {
  name         = "appointment"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "uuid"
  attribute {
    name = "uuid"
    type = "S"
  }
}