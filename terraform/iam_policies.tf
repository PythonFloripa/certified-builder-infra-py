resource "aws_iam_policy" "github_actions_sqs" {
  name        = "github-actions-sqs"
  description = "Allow Terraform GitHub Actions to manage project SQS queues"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sqs:CreateQueue",
        "sqs:DeleteQueue",
        "sqs:GetQueueAttributes",
        "sqs:SetQueueAttributes",
        "sqs:ListQueues",
        "sqs:TagQueue",
        "sqs:UntagQueue",
        "sqs:GetQueueUrl",
        "sqs:ListQueueTags"
      ]
      Resource = "arn:aws:sqs:${var.aws_region}:${var.aws_account_id}:${var.project_name}-*"
    }]
  })
}

resource "aws_iam_policy" "github_actions_ecr" {
  name        = "github-actions-ecr"
  description = "Allow Terraform GitHub Actions to manage project ECR repositories"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecr:CreateRepository",
        "ecr:DeleteRepository",
        "ecr:DescribeRepositories",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "ecr:PutLifecyclePolicy",
        "ecr:GetLifecyclePolicy",
        "ecr:DeleteLifecyclePolicy",
        "ecr:TagResource",
        "ecr:UntagResource"
      ]
      Resource = [
        "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/${var.project_name}-api",
        "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/${var.project_name}-builder",
        "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/${var.project_name}-notification"
      ]
    }]
  })
}

resource "aws_iam_policy" "github_actions_dynamodb" {
  name        = "github-actions-dynamodb"
  description = "Allow Terraform GitHub Actions to manage DynamoDB tables"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:CreateTable",
        "dynamodb:DeleteTable",
        "dynamodb:DescribeTable",
        "dynamodb:UpdateTable",
        "dynamodb:TagResource",
        "dynamodb:UntagResource"
      ]
      Resource = [
        "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.project_name}-certificates",
        "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.project_name}-orders",
        "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.project_name}-participants",
        "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.project_name}-products"
      ]
    }]
  })
}

resource "aws_iam_policy" "github_actions_apigw" {
  name        = "github-actions-apigateway"
  description = "Allow Terraform GitHub Actions to manage API Gateway resources"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "apigateway:GET",
        "apigateway:POST",
        "apigateway:PUT",
        "apigateway:PATCH",
        "apigateway:DELETE",
        "apigateway:TagResource",
        "apigateway:UntagResource"
      ]
      Resource = [
        "arn:aws:apigateway:${var.aws_region}::/restapis*",
        "arn:aws:apigateway:${var.aws_region}::/apikeys*",
        "arn:aws:apigateway:${var.aws_region}::/usageplans*",
        "arn:aws:apigateway:${var.aws_region}::/usageplankeys*",
        "arn:aws:apigateway:${var.aws_region}::/stages*",
        "arn:aws:apigateway:${var.aws_region}::/deployments*",
        "arn:aws:apigateway:${var.aws_region}::/resources*",
        "arn:aws:apigateway:${var.aws_region}::/methods*"
      ]
      Condition = {
        StringEquals = {
          "aws:ResourceTag/Project" = var.project_name
        }
      }
    }]
  })
}

resource "aws_iam_policy" "github_actions_lambda" {
  name        = "github-actions-lambda"
  description = "Allow Terraform GitHub Actions to manage Lambda functions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:CreateFunction",
          "lambda:DeleteFunction",
          "lambda:GetFunction",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:TagResource",
          "lambda:UntagResource",
          "lambda:PublishVersion",
          "lambda:CreateAlias",
          "lambda:DeleteAlias",
          "lambda:GetAlias",
          "lambda:UpdateAlias"
        ]
        Resource = [
          "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.project_name}-api",
          "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.project_name}-builder",
          "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.project_name}-notification"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:CreateEventSourceMapping",
          "lambda:DeleteEventSourceMapping",
          "lambda:GetEventSourceMapping",
          "lambda:UpdateEventSourceMapping",
          "lambda:ListEventSourceMappings"
        ]
        Resource = "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:event-source-mapping:*"
        Condition = {
          ArnEquals = {
            "lambda:FunctionArn" = [
              "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.project_name}-api",
              "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.project_name}-builder",
              "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.project_name}-notification"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_logs" {
  name        = "github-actions-logs"
  description = "Allow Terraform GitHub Actions to manage Lambda log groups"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:DeleteLogGroup",
        "logs:DescribeLogGroups",
        "logs:PutRetentionPolicy",
        "logs:TagResource",
        "logs:UntagResource"
      ]
      Resource = [
        "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${var.project_name}-api:*",
        "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${var.project_name}-builder:*",
        "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${var.project_name}-notification:*"
      ]
    }]
  })
}

resource "aws_iam_policy" "github_actions_s3" {
  name        = "github-actions-s3"
  description = "Allow Terraform GitHub Actions to manage project S3 buckets"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:PutBucketLifecycleConfiguration",
        "s3:GetBucketLifecycleConfiguration",
        "s3:DeleteBucketLifecycle",
        "s3:PutBucketTagging",
        "s3:GetBucketTagging",
        "s3:DeleteBucketTagging"
      ]
      Resource = [
        "arn:aws:s3:::${var.project_name}-bucket",
        "arn:aws:s3:::global-tf-state"
      ]
    }]
  })
}

resource "aws_iam_policy" "github_actions_iam_roles" {
  name        = "github-actions-iam-roles"
  description = "Allow Terraform GitHub Actions to manage Lambda IAM roles"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:GetRole",
        "iam:UpdateAssumeRolePolicy",
        "iam:TagRole",
        "iam:UntagRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies"
      ]
      Resource = [
        "arn:aws:iam::${var.aws_account_id}:role/${var.project_name}-lambda-role",
        "arn:aws:iam::${var.aws_account_id}:role/${var.project_name}-lambda-builder-role",
        "arn:aws:iam::${var.aws_account_id}:role/${var.project_name}-lambda-notification-role"
      ]
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          "arn:aws:iam::${var.aws_account_id}:role/${var.project_name}-lambda-role",
          "arn:aws:iam::${var.aws_account_id}:role/${var.project_name}-lambda-builder-role",
          "arn:aws:iam::${var.aws_account_id}:role/${var.project_name}-lambda-notification-role"
        ]
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "lambda.amazonaws.com"
          }
        }
    }]
  })
}

resource "aws_iam_policy" "github_actions_iam_policies" {
  name        = "github-actions-iam-policies"
  description = "Allow Terraform GitHub Actions to manage project-scoped IAM policies"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:CreatePolicyVersion",
        "iam:DeletePolicyVersion",
        "iam:ListPolicyVersions",
        "iam:TagPolicy",
        "iam:UntagPolicy"
      ]
      Resource = "arn:aws:iam::${var.aws_account_id}:policy/${var.project_name}-*"
    }]
  })
}

resource "aws_iam_policy" "github_actions_oidc" {
  name        = "github-actions-iam-oidc"
  description = "Allow Terraform GitHub Actions to manage the GitHub OIDC provider"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "iam:CreateOpenIDConnectProvider",
        "iam:DeleteOpenIDConnectProvider",
        "iam:TagOpenIDConnectProvider",
        "iam:UntagOpenIDConnectProvider",
        "iam:UpdateOpenIDConnectProviderThumbprint"
      ]
      Resource = aws_iam_openid_connect_provider.github.arn
    }]
  })
}
