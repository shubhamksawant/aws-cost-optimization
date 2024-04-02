provider "aws" {
  region = var.aws_region # Use a variable for the region
}

variable "aws_region" {
  type        = string
  default = "us-east-1"
  description = "The AWS region to deploy the resources"
}


data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function_payload.zip" # Specify the output path for the zip file

  source {
    content  = file("${path.module}/lambda_function.py") # Specify the path to your Python file
    filename = "lambda_function.py"                      # Specify the filename within the zip file
  }
}


resource "aws_lambda_function" "delete_unused_eips" {
  filename      = "lambda_function_payload.zip"  # Update with your Lambda function code
  function_name = "delete-unused-eips"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  environment {
    variables = {
      OWNER_TAG   = var.owner_tag
      PURPOSE_TAG = var.purpose_tag
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-policy"
  description = "Policy for Lambda function to delete unattached Elastic IPs"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "ec2:DescribeInstances",
        "ec2:DescribeAddresses",
        "ec2:ReleaseAddress"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

variable "owner_tag" {
  description = "Tag value for 'owner-dev' tag"
}

variable "purpose_tag" {
  description = "Tag value for 'purpose' tag"
}
