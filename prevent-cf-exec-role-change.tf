# Prevent altering or deleting the AWSCloudFormationStackSetExecutionRole unless is via stackset

data "aws_iam_policy_document" "prevent-changing-cloudformation-execution-role-outside-stacksets" {

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
      "iam:UntagRole"
    ]
    resources = [
      "arn:aws:iam::*:role/AWSCloudFormationStackSetExecutionRole"
    ]
    condition {
      test     = "ArnNotLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:role/stacksets-exec-*"]
    }
  }
}

resource "aws_organizations_policy" "prevent-changing-cloudformation-execution-role-outside-stacksets" {
  name        = "Prevent Changes in the AWSCloudFormationStackSetExecutionRole unless is via StackSets"
  description = "Prevent an account from changing the AWSCloudFormationStackSetExecutionRole unless via StackSets"

  content = data.aws_iam_policy_document.prevent-changing-cloudformation-execution-role-outside-stacksets.json
}