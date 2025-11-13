resource "aws_iam_role_policy_attachment" "github_actions_sqs" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_sqs.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ecr.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_dynamodb" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_dynamodb.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_apigw" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_apigw.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_lambda" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_lambda.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_logs" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_logs.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_s3" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_s3.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_iam_roles" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_iam_roles.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_iam_policies" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_iam_policies.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_oidc" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_oidc.arn
}
