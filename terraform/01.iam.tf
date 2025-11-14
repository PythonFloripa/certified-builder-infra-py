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
  # IAM permissions for Terraform plan/apply to read OIDC providers and policies
  statement {
    effect = "Allow"
    actions = [
      "iam:ListRoles",
      "iam:ListPolicies",
      "iam:ListPolicyVersions",
      "iam:ListOpenIDConnectProviders",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies"
    ]
    resources = ["*"]
  }

  # Get*/Read actions can be scoped to specific ARNs
  statement {
    effect = "Allow"
    actions = [
      "iam:GetOpenIDConnectProvider",
      "iam:GetPolicy",
      "iam:GetRole",
      "iam:GetPolicyVersion"
    ]
    resources = [
      "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com",
      "arn:aws:iam::${var.aws_account_id}:policy/github-actions-policy",
      "arn:aws:iam::${var.aws_account_id}:role/github-actions-assume-role"
    ]
  }
  # S3
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:CreateBucket",
    ]
    resources = [
      "arn:aws:s3:::tech-floripa-certificates-dev-tf-state",
      "arn:aws:s3:::tech-floripa-certificates-dev-tf-state/*",
      "arn:aws:s3:::tech-floripa-plan-artifacts",
      "arn:aws:s3:::tech-floripa-plan-artifacts/*"
    ]
  }

  # ECR
  statement {
    effect = "Allow"
    actions = [
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:DescribeRepositories",
      "ecr:ListTagsForResource",
      "ecr:TagResource",
      "ecr:UntagResource",
      "ecr:PutLifecyclePolicy",
      "ecr:GetLifecyclePolicy",
      "ecr:DeleteLifecyclePolicy",
      "ecr:PutImageScanningConfiguration",
      "ecr:PutImageTagMutability"
    ]
    resources = [
      "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/tech-floripa-certificates-*"
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
