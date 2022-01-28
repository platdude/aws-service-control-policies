# Prevent an account from leaving the organisation

data "aws_iam_policy_document" "prevent-leaving-orgs" {
  version = "2012-10-17"

  statement {
    effect = "Deny"

    actions = [
      "organizations:LeaveOrganization",
    ]

    resources = ["*"]
  }
}

resource "aws_organizations_policy" "prevent-leaving-orgs" {
  name        = "Prevent Leaving Organizations"
  description = "Prevents an account from leaving AWS Organizations"

  content = data.aws_iam_policy_document.prevent-leaving-orgs.json
}