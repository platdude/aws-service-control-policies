# Prevent changing default password policy unless is via CloudFormation StackSets

data "aws_iam_policy_document" "prevent-changing-default-password-policy" {
  statement {
    effect = "Deny"

    actions = [
      "iam:DeleteAccountPasswordPolicy",
      "iam:UpdateAccountPasswordPolicy"
    ]

    resources = ["*"]
    condition {
      test     = "ArnNotLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:role/IamPasswordPolicyLambdaRole"]
    }
  }
}

resource "aws_organizations_policy" "prevent-changing-default-password-policy" {
  name        = "Prevent Changing Default Password Policy"
  description = "Prevents an account from changing its default password policy"

  content = data.aws_iam_policy_document.prevent-changing-default-password-policy.json
}