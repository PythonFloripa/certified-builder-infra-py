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
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_org}/${var.github_repo}:*"]
    }
  }
}

### Github Action Role with Assume Role Policy Attached ###
resource "aws_iam_role" "github_actions_assume_role" {
  name               = "github-actions-assume-role"
  assume_role_policy = data.aws_iam_policy_document.github_action_assume_role.json
}

### IAM Permissions for Github Action Role
data "aws_iam_policy_document" "github_action_permissions" {
  # IAM for Lambda roles and policies
  statement {
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:GetOpenIDConnectProvider",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicyVersion",
      "iam:SetDefaultPolicyVersion"
    ]
    resources = ["*"]
  }

  # S3
  statement {
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:GetBucketAcl",
      "s3:GetBucketCors",
      "s3:GetBucketPolicy",
      "s3:GetBucketWebsite",
      "s3:PutBucketPolicy",
      "s3:PutBucketWebsite",
      "s3:DeleteBucketPolicy",
      "s3:DeleteBucketWebsite",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetLifecycleConfiguration",
      "s3:PutLifecycleConfiguration"

    ]
    resources = [
      "arn:aws:s3:::${var.project_name}-${var.environment}-state",
      "arn:aws:s3:::${var.project_name}-${var.environment}-state/*",
      "arn:aws:s3:::${var.project_name}-${var.environment}-bucket",
      "arn:aws:s3:::${var.project_name}-${var.environment}-bucket/*"
    ]
  }

  # ECR (split for least privilege)
  statement {
    effect = "Allow"
    actions = [
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:PutLifecyclePolicy",
      "ecr:GetLifecyclePolicy",
      "ecr:DeleteLifecyclePolicy",
      "ecr:ListTagsForResource",
      "ecr:TagResource",
      "ecr:UntagResource",
      "ecr:PutImageScanningConfiguration",
      "ecr:PutImageTagMutability"
    ]
    resources = [
      "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/tech-floripa-certificates-api-dev",
      "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/tech-floripa-certificates-builder-dev",
      "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/tech-floripa-certificates-notification-dev"
    ]
  }
  statement {
    effect    = "Allow"
    actions   = ["ecr:DescribeRepositories"]
    resources = ["*"]
  }

  # SQS
  statement {
    effect = "Allow"
    actions = [
      "sqs:CreateQueue",
      "sqs:DeleteQueue",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:SetQueueAttributes",
      "sqs:TagQueue",
      "sqs:UntagQueue",
      "sqs:ListQueueTags"
    ]
    resources = [
      "arn:aws:sqs:${var.aws_region}:${var.aws_account_id}:*",
    ]
  }
  statement {
    effect    = "Allow"
    actions   = ["sqs:ListQueues"]
    resources = ["*"]
  }

  # DynamoDB
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:CreateTable",
      "dynamodb:DeleteTable",
      "dynamodb:DescribeTable",
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTagsOfResource",
      "dynamodb:UpdateTable",
      "dynamodb:TagResource",
      "dynamodb:UntagResource",
      "dynamodb:DescribeTable"
    ]
    resources = [
      "arn:aws:dynamodb:*:*:table/*",

    ]
  }
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:ListTables"]
    resources = ["*"]
  }

  # Lambda
  statement {
    effect = "Allow"
    actions = [
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:GetFunction",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:TagResource",
      "lambda:UntagResource",
      "lambda:CreateEventSourceMapping",
      "lambda:DeleteEventSourceMapping",
      "lambda:GetEventSourceMapping",
      "lambda:UpdateEventSourceMapping",
      "lambda:AddPermission",
      "lambda:RemovePermission",
      "lambda:GetPolicy"
    ]
    resources = [
      "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.project_name}-api-${var.environment}",
      "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.project_name}-builder-${var.environment}",
      "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.project_name}-notification-${var.environment}"
    ]
  }
  statement {
    effect    = "Allow"
    actions   = ["lambda:ListTags", "lambda:ListEventSourceMappings"]
    resources = ["*"]
  }

  # API Gateway
  statement {
    effect = "Allow"
    actions = [
      "apigateway:POST",
      "apigateway:PUT",
      "apigateway:GET",
      "apigateway:DELETE",
      "apigateway:PATCH"
    ]
    resources = [
      "arn:aws:apigateway:${var.aws_region}::/restapis/*"
    ]
  }

  # CloudWatch Logs
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:TagResource",
      "logs:UntagResource"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${var.project_name}-api-${var.environment}",
      "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${var.project_name}-builder-${var.environment}",
      "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${var.project_name}-notification-${var.environment}"
    ]
  }
  statement {
    effect    = "Allow"
    actions   = ["logs:DescribeLogGroups"]
    resources = ["*"]
  }

  # Permissão específica para a Role atualizar sua própria política
  statement {
    effect = "Allow"
    actions = [
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicyVersion",
      "iam:SetDefaultPolicyVersion"
    ]
    resources = [
      "arn:aws:iam::${var.aws_account_id}:policy/github-actions-policy"
    ]
  }
}

resource "aws_iam_policy" "github_actions_policy" {
  name        = "github-actions-policy"
  description = "Permissions for GitHub Actions to manage project resources"
  policy      = data.aws_iam_policy_document.github_action_permissions.json
}

resource "aws_iam_role_policy_attachment" "github_actions_policy_attachment" {
  role       = aws_iam_role.github_actions_assume_role.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}
