data "aws_iam_policy_document" "policies" {
  for_each = var.services_accounts

  dynamic "statement" {
    for_each = each.value.statements
    content {
      effect    = statement.value.Effect
      actions   = statement.value.Action
      resources = statement.value.Resource

    }
  }
}

locals {
  oidc = {
    arn = aws_iam_openid_connect_provider.oidc.arn
    url = replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")
  }
}

resource "aws_iam_role_policy" "eks-Service_Accounts" {
  for_each = aws_iam_role.eks-Service-Account

  role = each.value.name

  policy = data.aws_iam_policy_document.policies[each.key].json
}

resource "aws_iam_role" "eks-Service-Account" {
  for_each = var.services_accounts

  name = "${each.value.namespace}-service-account"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${local.oidc.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${local.oidc.url}:aud": "sts.amazonaws.com",
          "${local.oidc.url}:sub": "system:serviceaccount:${each.value.namespace}:service-account"
        }
      }
    }
  ]
}
EOF
}
