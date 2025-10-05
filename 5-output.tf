output "s3_source_bucket_name" {
  value = aws_s3_bucket.resize.id
}

output "s3_output_bucket_name" {
  value = aws_s3_bucket.resize_output.id
}
