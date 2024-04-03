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


resource "aws_lambda_function" "start_stop_instances" {
  filename      = "lambda_function_payload.zip" # Update with your Lambda function code
  function_name = "start-stop-instances"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60 # Update timeout to 60 seconds
  environment {
    variables = {
      OWNER_TAG   = var.owner_tag
      PURPOSE_TAG = var.purpose_tag
      REGION      = var.aws_region

    }
  }
}

resource "aws_cloudwatch_event_rule" "invoke_lambda_morning" {
  name                = "invoke-lambda-on-morning"
  schedule_expression = "cron(0 9 ? * MON-FRI *)" # Schedule to run at 9 AM on weekdays
}

resource "aws_cloudwatch_event_rule" "invoke_lambda_evening" {
  name                = "invoke-lambda-on-evening"
  schedule_expression = "cron(0 18 ? * MON-FRI *)" # Schedule to run at 6 PM on weekdays
}

resource "aws_cloudwatch_event_target" "lambda_target_morning" {
  rule      = aws_cloudwatch_event_rule.invoke_lambda_morning.name
  target_id = "invoke-lambda-morning"
  arn       = aws_lambda_function.start_stop_instances.arn
}

resource "aws_cloudwatch_event_target" "lambda_target_evening" {
  rule      = aws_cloudwatch_event_rule.invoke_lambda_evening.name
  target_id = "invoke-lambda-evening"
  arn       = aws_lambda_function.start_stop_instances.arn
}

variable "owner_tag" {
  description = "Tag value for 'owner' tag"
}

variable "purpose_tag" {
  description = "Tag value for 'purpose' tag"
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
  description = "Policy for Lambda function to start stop instance"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ec2:DescribeInstances",
        "ec2:DescribeAddresses",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment2" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_permission" "allow_lambda_target_morning_to_call_start_stop_instances" {
  statement_id  = "AllowExecutionFromCloudWatch1"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_stop_instances.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_lambda_morning.arn
}


resource "aws_lambda_permission" "allow_lambda_target_evening_to_call_start_stop_instances" {
  statement_id  = "AllowExecutionFromCloudWatch2"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_stop_instances.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_lambda_evening.arn
}


