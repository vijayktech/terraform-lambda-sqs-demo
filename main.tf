provider "aws" {
  region = "ap-south-1"
}

resource "aws_sqs_queue" "terraform-q" {
  name = "examplequeue"
}

# 'examplequeue-ddl' is queue which dead letter queue for 'examplequeue' queue
# If messages from examplequeue queue is not reached to destination then those messages move to dead letter queue
resource "aws_sqs_queue" "ddl" {
  name = "examplequeue-ddl"
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.terraform-q.arn]
  })
}

# attaching policy dead letter queue for 'examplequeue' and 'examplequeue-ddl'
resource "aws_sqs_queue_redrive_policy" "terraform-q" {
  queue_url = aws_sqs_queue.terraform-q.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.ddl.arn
    maxReceiveCount     = 4
  })
}

data "aws_iam_policy_document" "sqs_cloudwatch_ploicy_doc" {
  statement {
    actions   = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [
      aws_sqs_queue.terraform-q.arn
    ]
  }
  statement {
    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

resource "aws_iam_policy" "cloudwatch_sqs_policy" {
  name   = "cloudwatch_sqs_policy"
  policy = data.aws_iam_policy_document.sqs_cloudwatch_ploicy_doc.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_sqs_policy_attach" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.cloudwatch_sqs_policy.arn
}

data "archive_file" "zip_the_python_code" {
  source_dir = "${path.module}/python"
  output_path = "${path.module}/python/hello-python.zip"
  type        = "zip"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
}

resource "aws_lambda_function" "test_lambda" {
  filename = "${path.module}/python/hello-python.zip"
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.8"
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  function_name = aws_lambda_function.test_lambda.arn
  event_source_arn = aws_sqs_queue.terraform-q.arn
  enabled = true
  batch_size = 1
}