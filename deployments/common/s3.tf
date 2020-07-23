//create S3 bucket
resource "aws_s3_bucket" "PythonLambdaDeploy" {
  bucket = "${var.deploy_env}-${var.demo_type}-lambda-deploy-coaching-demo"
  force_destroy = true
  acl = "private"

  tags = {
    Name = "Lambda Deploy"
    Environment = var.deploy_env
  }
}


resource "aws_s3_bucket_object" "PythonUploadProject" {
  bucket = aws_s3_bucket.PythonLambdaDeploy.bucket
  key = "lambda_python.zip"
  source = "../../lambda_python.zip"
  depends_on = [aws_s3_bucket.PythonLambdaDeploy]
  etag = filemd5("../../lambda_python.zip")
}


#copy all the files from a directory
resource "aws_s3_bucket_object" "static-site-files" {
  for_each = fileset("../../Application/build", "**/*.*")
  bucket = aws_s3_bucket.PythonLambdaDeploy.bucket
  key = each.value
  source = "../../Application/build/${each.value}"
}