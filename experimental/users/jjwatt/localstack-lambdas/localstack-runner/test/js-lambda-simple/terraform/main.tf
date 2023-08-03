data "archive_file" "main_handler_zip" {
  type = "zip"
  output_path = "out/main_handler.zip"
  source_dir = "src"
}

resource "aws_lambda_function" "lambda" {
  description      = var.description
  filename         = data.archive_file.main_handler_zip.output_path
  function_name    = var.function_name
  handler          = var.lambda_handler
  role             = aws_iam_role.lambda.arn
  runtime          = var.runtime
  source_code_hash = data.archive_file.main_handler_zip.ouput_base64sha256

  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions
  dynamic "environment" {
    for_each = length(keys(var.environment_variables)) == 0 ? [] : [true]
    content {
      variables = var.environment_variables
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.function_name}-${data.aws_region.current.name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_region" "current" {}

