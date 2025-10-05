resource "aws_s3_bucket" "resize" {
  bucket_prefix = "resize-source-"
  force_destroy = true
}

resource "aws_s3_bucket_notification" "resize_notification" {
  bucket = aws_s3_bucket.resize.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.resize.arn
    events              = ["s3:ObjectCreated:Put"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

# Output bucket
resource "aws_s3_bucket" "resize_output" {
  bucket_prefix = "resize-output-"
  force_destroy = true
}



############# Test file 
