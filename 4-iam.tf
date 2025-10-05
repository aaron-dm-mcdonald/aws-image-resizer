data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "resize" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "resize" {
  name = "lambda_s3_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        # Read from source bucket
        Effect = "Allow",
        Action = ["s3:GetObject"],
        Resource = [
          "${aws_s3_bucket.resize.arn}/*"
        ]
      },
      {
        # Write to output bucket
        Effect = "Allow",
        Action = ["s3:PutObject"],
        Resource = [
          "${aws_s3_bucket.resize_output.arn}/*"
        ]
      },
      {
        # CloudWatch Logs
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.resize.name
  policy_arn = aws_iam_policy.resize.arn
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.resize.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.resize.arn
}