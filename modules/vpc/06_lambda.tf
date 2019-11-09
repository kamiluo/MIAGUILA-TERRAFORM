##################################################################################################
#--IAM ROLES FOR LAMBDAS
##################################################################################################
resource "aws_iam_role" "iam_role_ma_lambda" {
  name = "iam_role_ma_lambda"

  assume_role_policy = <<EOF
{
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
}
EOF
}

resource "aws_iam_policy" "iam_policy_ma_lambda_cloudwatch" {
  name = "iam_policy_ma_lambda_cloudwatch"
  path = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_policy_ma_lambda" {
  role = "${aws_iam_role.iam_role_ma_lambda.name}"
  policy_arn = "${aws_iam_policy.iam_policy_ma_lambda_cloudwatch.arn}"
  depends_on = [
                "aws_iam_policy.iam_policy_ma_lambda_cloudwatch",
                "aws_iam_role.iam_role_ma_lambda"
               ]
}

############################################################################################################
#---- LAMBDA
############################################################################################################

resource "aws_lambda_function" "lambda_ma_1min" {
    filename = "lambda.zip"
    function_name = "lambda_ma_1min"
    role = "${aws_iam_role.iam_role_ma_lambda.arn}"
    handler = "lambda_function.lambda_handler"
    source_code_hash = "${filebase64sha256("lambda.zip")}"
    runtime = "python3.7"
    depends_on = ["aws_iam_role_policy_attachment.attach_policy_ma_lambda"]
}

resource "aws_lambda_function" "lambda_ma_15min" {
    filename = "lambda.zip"
    function_name = "lambda_ma_15min"
    role = "${aws_iam_role.iam_role_ma_lambda.arn}"
    handler = "lambda_function.lambda_handler"
    source_code_hash = "${filebase64sha256("lambda.zip")}"
    runtime = "python3.7"
    depends_on = ["aws_iam_role_policy_attachment.attach_policy_ma_lambda"]
}

resource "aws_lambda_function" "lambda_ma_60min" {
    filename = "lambda.zip"
    function_name = "lambda_ma_60min"
    role = "${aws_iam_role.iam_role_ma_lambda.arn}"
    handler = "lambda_function.lambda_handler"
    source_code_hash = "${filebase64sha256("lambda.zip")}"
    runtime = "python3.7"
    depends_on = ["aws_iam_role_policy_attachment.attach_policy_ma_lambda"]
}

################################################################################################
#--CLOUDWATCH RULES FOR SCHEDULE LAMBDAS EXECUTIONS
################################################################################################
#------------- 1min
resource "aws_cloudwatch_event_rule" "cl_rule_ma_1min" {
    name = "cl_rule_ma_1min"
    description = "Fires every 1 minute"
    schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "cl_target_ma_1min" {
    rule = "${aws_cloudwatch_event_rule.cl_rule_ma_1min.name}"
    target_id = "cl_target_ma_1min"
    arn = "${aws_lambda_function.lambda_ma_1min.arn}"
}

resource "aws_lambda_permission" "trigger_lambda_1m" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.lambda_ma_1min.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.cl_rule_ma_1min.arn}"
}
#------------- 15min
resource "aws_cloudwatch_event_rule" "cl_rule_ma_15min" {
    name = "cl_rule_ma_15min"
    description = "Fires every 15 minutes"
    schedule_expression = "rate(15 minutes)"
}

resource "aws_cloudwatch_event_target" "cl_target_ma_15min" {
    rule = "${aws_cloudwatch_event_rule.cl_rule_ma_15min.name}"
    target_id = "cl_target_ma_15min"
    arn = "${aws_lambda_function.lambda_ma_15min.arn}"
}

resource "aws_lambda_permission" "trigger_lambda_15m" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.lambda_ma_15min.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.cl_rule_ma_15min.arn}"
}
#------------- 60min
resource "aws_cloudwatch_event_rule" "cl_rule_ma_60min" {
    name = "cl_rule_ma_60min"
    description = "Fires every 60 minutes"
    schedule_expression = "rate(60 minutes)"
}

resource "aws_cloudwatch_event_target" "cl_target_ma_60min" {
    rule = "${aws_cloudwatch_event_rule.cl_rule_ma_60min.name}"
    target_id = "cl_target_ma_60min"
    arn = "${aws_lambda_function.lambda_ma_60min.arn}"
}

resource "aws_lambda_permission" "trigger_lambda_60min" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.lambda_ma_60min.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.cl_rule_ma_60min.arn}"
}
