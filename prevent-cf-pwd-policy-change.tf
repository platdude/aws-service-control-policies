# Prevent changing resources that enforce password policy unless is via Cloudformation StackSets
# This SCP prevents resources deployed by https://github.com/platdude/aws-cloudformation/blob/f172f16c48cfc4c5e7369f1a116668dee2f45d9d/password_policy.yml
# from being altered.

data "aws_iam_policy_document" "prevent-changing-cloudformation-resources-outside-stacksets" {
  statement {
    effect = "Deny"
    actions = [
      "cloudformation:CancelUpdateStack",
      "cloudformation:ContinueUpdateRollback",
      "cloudformation:CreateChangeSet",
      "cloudformation:CreateStack",
      "cloudformation:TagResource",
      "cloudformation:UnTagResource",
      "cloudformation:ExecuteChangeSet",
      "cloudformation:SetStackPolicy",
      "cloudformation:UpdateTerminationProtection",
      "cloudformation:UpdateStack"
    ]
    resources = ["*"]
    condition {
      test     = "ArnNotLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:role/stacksets-exec-*"]
    }
    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/ManagedBy"
      values   = ["stackset"]
    }
  }
  # Do not allow changing IamPasswordPolicyLambda and its associated IamPasswordPolicyLambdaRole unless is via stackset
  statement {
    effect = "Deny"
    actions = [
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:PassRole",
      "iam:PutRolePermissionsBoundary",
      "iam:PutRolePolicy",
      "iam:TagRole",
      "iam:UpdateRoleDescription",
      "iam:UpdateRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:UntagRole",
      "lambda:AddPermission",
      "lambda:DeleteAlias",
      "lambda:DeleteFunction",
      "lambda:DeleteLayerVersion",
      "lambda:InvokeFunction",
      "lambda:PublishLayerVersion",
      "lambda:PublishVersion",
      "lambda:TagResource",
      "lambda:UntagResource",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:RemovePermission"
    ]
    resources = [
      "arn:aws:iam::*:role/IamPasswordPolicyLambdaRole",
      "arn:aws:lambda:*:*:function:IamPasswordPolicyLambda"
    ]
    condition {
      test     = "ArnNotLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:role/stacksets-exec-*"]
    }
  }
}

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

data "aws_iam_policy_document" "protect_enforced_password_policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.prevent-changing-cloudformation-resources-outside-stacksets.json,
    data.aws_iam_policy_document.prevent-changing-default-password-policy.json
  ]
}

resource "aws_organizations_policy" "prevent-changing-enforced-password-policy-outside-stacksets" {
  name        = "Prevent Changes in Cloudformation Resources deployed by StackSets unless is via StackSets"
  description = "Prevent an account from changing StackSet Cloudformation Resources unless via StackSets"

  content = data.aws_iam_policy_document.protect_enforced_password_policy.json
}