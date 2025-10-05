resource "aws_lambda_function" "resize" {
  function_name = "s3_resize_function"
  role          = aws_iam_role.resize.arn
  runtime       = "python3.11"
  handler       = "lambda_function.lambda_handler"
  filename      = data.archive_file.lambda.output_path

  source_code_hash = data.archive_file.lambda.output_base64sha256

  # Performance and reliability settings
  timeout     = 30  # 30 seconds for processing larger images
  memory_size = 512 # 512 MB - good balance for image processing

  layers = [local.pillow_layer_arn]

  environment {
    variables = {
      DESTINATION_BUCKETNAME = aws_s3_bucket.resize_output.id
    }
  }



  depends_on = [
    aws_iam_role_policy_attachment.attach_policy
  ]
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "./src/lambda_function.py"
  output_path = "./src/lambda_function_payload.zip"
}

# Use existing public Pillow layer
# Reference: https://docs.aws.amazon.com/lambda/latest/dg/python-layers.html
# THE GOAT: https://github.com/keithrozario/Klayers/tree/master/deployments
locals {
  pillow_layer_arn = "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p311-Pillow:9"
}