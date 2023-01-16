data "aws_s3_object" "appointment_lambda_artefact" {
  bucket = "appointment-artefact-bucket"
  key    = "lambda/appointment.zip"
}

resource "aws_lambda_function" "appointment_lambda" {
  s3_bucket         = data.aws_s3_object.appointment_lambda_artefact.bucket
  s3_key            = data.aws_s3_object.appointment_lambda_artefact.key
  s3_object_version = data.aws_s3_object.appointment_lambda_artefact.version_id
  function_name    = "appointment-lambda"
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  timeout          = 30
  role             = "${aws_iam_role.appointment_lambda_iam_access_role.name}"
}
resource "aws_iam_policy" "appointment_lambda_iam_access_policy" {
  name        = "appointment-lambda-iam-access-policy"
  description = "IAM policy for appointment lambda"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::appointment-artefact-bucket",
                "arn:aws:s3:::appointment-artefact-bucket/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchGetItem",
                "dynamodb:GetItem",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchWriteItem",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem"
            ],
            "Resource": "arn:aws:dynamodb:eu-west-2:000000000000:table/appointment"
    },
        {
          "Action": [
            "autoscaling:Describe*",
            "cloudwatch:*",
            "logs:*",
            "sns:*"
          ],
          "Effect": "Allow",
          "Resource": "*"
        }
  ]
}
  EOF
}
resource "aws_iam_role" "appointment_lambda_iam_access_role" {
  name               = "appointment-lambda-iam-access-role"
  path               = "/"
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
resource "aws_iam_role_policy_attachment" "appointment_lambda_iam_access_policy_attach" {
  role       = "${aws_iam_role.appointment_lambda_iam_access_role.name}"
  policy_arn = "${aws_iam_policy.appointment_lambda_iam_access_policy.arn}"
}