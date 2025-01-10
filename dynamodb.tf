resource "aws_dynamodb_table" "words_table" {
  name           = "WordsTable"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "word"
  attribute {
    name = "word"
    type = "S"
  }
}
