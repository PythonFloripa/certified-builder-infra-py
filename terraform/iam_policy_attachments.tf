locals {
  github_actions_policy_arns = {
    sqs          = try(aws_iam_policy.github_actions_sqs.arn, null)
    ecr          = try(aws_iam_policy.github_actions_ecr.arn, null)
    dynamodb     = try(aws_iam_policy.github_actions_dynamodb.arn, null)
    apigw        = try(aws_iam_policy.github_actions_apigw.arn, null)
    lambda       = try(aws_iam_policy.github_actions_lambda.arn, null)
    logs         = try(aws_iam_policy.github_actions_logs.arn, null)
    s3           = try(aws_iam_policy.github_actions_s3.arn, null)
    iam_roles    = try(aws_iam_policy.github_actions_iam_roles.arn, null)
    iam_policies = try(aws_iam_policy.github_actions_iam_policies.arn, null)
    oidc         = try(aws_iam_policy.github_actions_oidc.arn, null)
  }
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  for_each = { for key, arn in local.github_actions_policy_arns : key => arn if arn != null }

  role       = aws_iam_role.github_actions.name
  policy_arn = each.value
}
