# Prevent changing billing details

data "aws_iam_policy_document" "prevent-billing-changes" {
  version = "2012-10-17"

  statement {
    effect = "Deny"

    actions = [
      "aws-portal:ModifyAccount",
      "aws-portal:ModifyBilling",
      "aws-portal:ModifyPaymentMethods",
    ]

    resources = ["*"]
  }
}

resource "aws_organizations_policy" "prevent-billing-changes" {
  name        = "Prevent Billing Changes"
  description = "Prevents an account from making billing changes"

  content = data.aws_iam_policy_document.prevent-billing-changes.json
}