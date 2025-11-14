# --- IAM OIDC Provider for GitHub Actions ---
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

locals {
  github_oidc_subject_prefix = "repo:${var.github_org}/${var.github_repo}:"
  github_oidc_allowed_subjects = [
    for ref in var.github_oidc_allowed_refs : "${local.github_oidc_subject_prefix}${ref}"
  ]
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    sid    = "GithubActionsOidcAssumeRole"
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
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
      values   = local.github_oidc_allowed_subjects
    }
  }
}

# --- IAM Role for GitHub Actions OIDC ---
resource "aws_iam_role" "github_actions" {
  name               = "github-actions-terraform-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}
