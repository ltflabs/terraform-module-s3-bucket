##################################################
# Data Sources
##################################################
data "aws_ssm_parameter" "role_path" {
  name = var.role_path
}

data "aws_iam_role" "programatic_role" {
  name = data.aws_ssm_parameter.role_path.value
}


##################################################
# Resources
##################################################

resource "aws_s3_bucket" "this_bucket" {
  bucket_prefix = var.service_name != "" ? var.service_name : var.bucket_name

  tags = {
    Name = "initail_test_bucket"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}


data "aws_iam_policy_document" "allow_role_based_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_role.programatic_role.arn]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = ["aws_s3_bucket.this_bucket.arn",
      "${aws_s3_bucket.this_bucket.arn}/*"
    ]

    condition {
      test     = "StringLike"
      variable = "aws:userid"
      values = ["${data.aws_iam_role.programatic_role.unique_id}*",
      var.accountId != "" ? var.accountId : 11111111]
    }
  }
}

resource "aws_s3_bucket_policy" "this_bucket_policy" {
  count = var.put_bucket_policy ? 1 : 0

  bucket = aws_s3_bucket.this_bucket.id
  policy = data.aws_iam_policy_document.allow_role_based_access.json

}

//Add lifecycle rule
