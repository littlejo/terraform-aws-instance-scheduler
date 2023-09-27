locals {
  target = {
    ec2 = {
      json = jsonencode({
        InstanceIds = var.target
      })
      start = {
        arn = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
      }
      stop = {
        arn = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
      }
    }
    rds = {
      json = jsonencode({
        DbInstanceIdentifier = var.target
      })
      start = {
        arn = "arn:aws:scheduler:::aws-sdk:rds:startDBInstance"
      }
      stop = {
        arn = "arn:aws:scheduler:::aws-sdk:rds:stopDBInstance"
      }
    }
  }

  schedule = {
    weekend = {
      stop  = "cron(0 18 ? * FRI *)"
      start = "cron(0 9 ? * MON *)"
    }
    night = {
      stop  = "cron(0 18 ? * MON-THU *)"
      start = "cron(0 9 ? * TUE-FRI *)"
    }
  }
}

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

resource "aws_scheduler_schedule" "stop" {
  name       = "stop-${var.period}-${var.name}"
  group_name = var.group_name

  schedule_expression_timezone = var.timezone

  flexible_time_window {
    mode                      = var.flexible_time_window.mode
    maximum_window_in_minutes = var.flexible_time_window.maximum_window_in_minutes
  }

  schedule_expression = local.schedule[var.period].stop

  target {
    arn      = local.target[var.type].stop.arn
    role_arn = var.create_iam_role ? aws_iam_role.this[0].arn : var.iam_role_arn

    input = local.target[var.type].json
  }
}

resource "aws_scheduler_schedule" "start" {
  name       = "start-${var.period}-${var.name}"
  group_name = var.group_name

  schedule_expression_timezone = var.timezone

  flexible_time_window {
    mode                      = var.flexible_time_window.mode
    maximum_window_in_minutes = var.flexible_time_window.maximum_window_in_minutes
  }

  schedule_expression = local.schedule[var.period].start

  target {
    arn      = local.target[var.type].start.arn
    role_arn = var.create_iam_role ? aws_iam_role.this[0].arn : var.iam_role_arn

    input = local.target[var.type].json
  }
}
