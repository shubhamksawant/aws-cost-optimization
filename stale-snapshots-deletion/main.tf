provider "aws" {
  region = var.aws_region # Use a variable for the region
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
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

resource "aws_lambda_function" "stale-snapshots-deletion-lambda" {
  filename      = "lambda_function_payload.zip" # Update with your Lambda function code
  function_name = "stale-snapshots-deletion"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60 # Update timeout to 60 seconds
}

resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "daily-trigger"
  schedule_expression = "cron(0 0 * * ? *)" # Schedule to trigger every day at 00:00 UTC

}

resource "aws_cloudwatch_event_target" "lambda_target_stale-snapshots-deletion" {
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  target_id = "stale-snapshots-deletion-lambda"
  arn       = aws_lambda_function.stale-snapshots-deletion-lambda.arn
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" # Attach basic Lambda execution policy
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-policy"
  description = "Policy for Lambda function to delete stale snapshots"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ec2:DescribeInstances",
        "ec2:DescribeAddresses",
        "ec2:DeleteSnapshot",
        "ec2:DescribeVolumes",
        "ec2:DescribeSnapshots"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment2" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_permission" "allow_lambda_stale-snapshots-deletion" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stale-snapshots-deletion-lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}

