data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2" {
  statement {
    actions   = ["ec2:startInstances", "ec2:stopInstances"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "rds" {
  statement {
    actions   = ["rds:startDBInstance", "rds:stopDBInstance"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "this" {
  count = var.create_iam_role ? 1 : 0

  name_prefix        = "role-scheduler"
  description        = "Role for eventbridge scheduler"
  assume_role_policy = data.aws_iam_policy_document.assume.json

  inline_policy {
    name   = "ec2"
    policy = data.aws_iam_policy_document.ec2.json
  }

  inline_policy {
    name   = "rds"
    policy = data.aws_iam_policy_document.rds.json
  }
}

