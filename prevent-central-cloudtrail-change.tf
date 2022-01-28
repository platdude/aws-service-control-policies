# Prevent changing central Cloudtrail configuration and S3 bucket & objects unless is via stackset
# This SCP is meant to protect configuration deployed to enable centralised CloudTrail logs 
# analysis with S3 as a backend storage. Variables files are not included, since this are not 
# part of a life Terraform config.

data "aws_iam_policy_document" "prevent-changing-cloudformation-cloudtrail-central-resources-outside-stacksets" {
  statement {
    effect = "Deny"
    actions = [
      "s3:Delete*",
      "s3:Put*",
      "cloudtrail:Create*",
      "cloudtrail:AddTags",
      "cloudtrail:CancelQuery",
      "cloudtrail:Delete*",
      "cloudtrail:Put*",
      "cloudtrail:RemoveTags",
      "cloudtrail:Update*"
    ]
    resources = [
      "arn:aws:cloudtrail:*:${var.central_cloudtrail_account_id}:trail/${var.central_cloudtrail_trail_name}",
      "arn:aws:s3:::${var.central_cloudtrail_bucket_name}",
      "arn:aws:s3:::${var.central_cloudtrail_bucket_name}/*"
    ]
    condition {
      test     = "ArnNotLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:role/stacksets-exec-*"]
    }
  }
}

resource "aws_organizations_policy" "prevent-changing-cloudformation-cloudtrail-central-resources-outside-stacksets" {
  name        = "Prevent Changes in the resources that allow central CloudTrail logging unless is via StackSets"
  description = "Prevent an account from changing the central CloudTrail resources unless is via StackSets"

  content = data.aws_iam_policy_document.prevent-changing-cloudformation-cloudtrail-central-resources-outside-stacksets.json
}