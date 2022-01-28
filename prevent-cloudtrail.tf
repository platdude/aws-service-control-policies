# Prevent stopping logging in CloudTrail 

data "aws_iam_policy_document" "prevent-stopping-cloudtrail" {
  version = "2012-10-17"

  statement {
    effect = "Deny"

    actions = [
      "cloudtrail:StopLogging",
    ]

    resources = ["*"]
  }
}

resource "aws_organizations_policy" "prevent-stopping-cloudtrail" {
  name        = "Prevent stopping Cloudtrail"
  description = "Prevents an account from turning off cloudtrail"

  content = data.aws_iam_policy_document.prevent-stopping-cloudtrail.json
}