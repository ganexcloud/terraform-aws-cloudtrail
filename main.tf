data "aws_caller_identity" "default" {
}

data "aws_region" "default" {
}

resource "aws_cloudtrail" "default" {
  name                          = var.name
  enable_logging                = var.enable_logging
  s3_bucket_name                = aws_s3_bucket.default.id
  enable_log_file_validation    = var.enable_log_file_validation
  is_multi_region_trail         = var.is_multi_region_trail
  include_global_service_events = var.include_global_service_events
  cloud_watch_logs_group_arn    = join("", aws_cloudwatch_log_group.cloudtrail.*.arn)
  cloud_watch_logs_role_arn     = join("", aws_iam_role.cloudwatch_logs.*.arn)
  tags                          = var.tags
  kms_key_id                    = var.kms_key_id
  is_organization_trail         = var.is_organization_trail

  dynamic "event_selector" {
    for_each = var.event_selector
    content {
      include_management_events = lookup(event_selector.value, "include_management_events", null)
      read_write_type           = lookup(event_selector.value, "read_write_type", null)

      dynamic "data_resource" {
        for_each = lookup(event_selector.value, "data_resource", [])
        content {
          type   = data_resource.value.type
          values = data_resource.value.values
        }
      }
    }
  }
  depends_on = [aws_s3_bucket_policy.default]
}

resource "aws_s3_bucket" "default" {
  bucket        = var.name
  acl           = "log-delivery-write"
  force_destroy = var.force_destroy
  tags          = var.tags
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_policy" "default" {
  bucket = aws_s3_bucket.default.id
  policy = data.aws_iam_policy_document.default.json
}

data "aws_iam_policy_document" "default" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      "arn:aws:s3:::${var.name}",
    ]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${var.name}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control",
      ]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_assume_role" {
  count = var.enable_cloudwatchlogs == true ? 1 : 0

  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = [
        "cloudtrail.amazonaws.com",
      ]

      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_logs_role" {
  count = var.enable_cloudwatchlogs == true ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.cloudtrail[0].arn}"]

    sid = "AWSCloudTrailLogging"
  }
}

resource "aws_iam_role" "cloudwatch_logs" {
  count              = var.enable_cloudwatchlogs == true ? 1 : 0
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume_role[0].json
  name               = "CloudTrail_CloudWatchLogs_Role-${var.name}"
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  count             = var.enable_cloudwatchlogs == true ? 1 : 0
  name              = "CloudTrail/${var.name}"
  retention_in_days = 30
}

resource "aws_iam_role_policy" "cloudwatch_logs" {
  count  = var.enable_cloudwatchlogs == true ? 1 : 0
  name   = "cloudwatch-logs"
  policy = data.aws_iam_policy_document.cloudwatch_logs_role[0].json
  role   = aws_iam_role.cloudwatch_logs[0].id
}
