### OpenID Provider for Github ###
resource "aws_iam_openid_connect_provider" "github_provider" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

### Assume Role Policy ###
data "aws_iam_policy_document" "github_action_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_provider.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_org}/*"]
    }
  }
}

### Github Action Role with Assume Role Policy Attached ###
resource "aws_iam_role" "github_actions_assume_role" {
  name               = "github-actions-assume-role"
  assume_role_policy = data.aws_iam_policy_document.github_action_assume_role.json
}

# ### IAM Permissions for Github Action Role
# data "aws_iam_policy_document" "gh_policy_document" {
#   # SQS
#   statement {
#     effect = "Allow"

#     actions = [

#     ]

#     resources = [
#       "arn:aws:sqs:${var.aws_region}:${var.aws_account_id}:${var.project_name}-*",
#     ]
#   }
#   # ECR
#   statement {
#     effect = "Allow"

#     actions = [

#     ]

#     resources = [
#       "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/${var.project_name}-*",
#     ]
#   }
#   # DynamoDB
#   statement {
#     effect = "Allow"

#     actions = [

#     ]
#     resources = [
#       "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.project_name}-*",
#     ]
#   }
#   # API Gateway
#   statement {
#     effect = "Allow"

#     actions = [
#     ]

#     resources = [
#       "arn:aws:apigateway:*::/*",
#     ]
#   }
#   # Lambda
#   statement {
#     effect = "Allow"

#     actions = [

#     ]
#     resources = [
#       "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.project_name}-*",
#     ]
#   }
#   # CloudWatch Logs
#   statement {
#     effect = "Allow"

#     actions = [

#     ]

#     resources = [
#       "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:${var.project_name}-*",
#     ]
#   }

#   # S3
#   statement {
#     effect = "Allow"

#     actions = [

#     ]

#     resources = ["*"]
#   }

#   # IAM
#   statement {
#     effect = "Allow"

#     actions = [
#     ]

#     resources = [

#     ]
#   }
# }

# resource "aws_iam_policy" "github_actions_policy" {
#   name        = "github-actions-policy"
#   description = "Permissions for GitHub Actions to manage project resources"
#   policy      = data.       aws_iam_policy_document.github_actions_policy.json
# }

# resource "aws_iam_role_policy   _attachment" "github_actions_policy_attachment" {
#   role       = aws_iam_role.github_actions_assume_role.name
#   policy_arn = aws_iam_policy.github_actions_policy.arn
# }
