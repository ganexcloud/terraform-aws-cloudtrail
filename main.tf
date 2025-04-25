data "aws_caller_identity" "default" {}
data "aws_region" "default" {}

resource "aws_cloudtrail" "default" {
  name                          = var.name
  enable_logging                = var.enable_logging
  s3_bucket_name                = var.create_s3_bucket ? aws_s3_bucket.default[0].id : var.s3_bucket_name
  enable_log_file_validation    = var.enable_log_file_validation
  is_multi_region_trail         = var.is_multi_region_trail
  include_global_service_events = var.include_global_service_events
  cloud_watch_logs_group_arn    = var.enable_cloudwatchlogs ? "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*" : null
  cloud_watch_logs_role_arn     = var.enable_cloudwatchlogs ? join("", aws_iam_role.cloudwatch_logs.*.arn) : null
  tags                          = var.tags
  kms_key_id                    = var.kms_key_id
  is_organization_trail         = var.is_organization_trail

  dynamic "event_selector" {
    for_each = var.event_selector
    content {
      include_management_events = lookup(event_selector.value, "include_management_events", null)
      read_write_type           = lookup(event_selector.value, "read_write_type", null)

      data_resource {
        type   = event_selector.value.data_resource.type
        values = event_selector.value.data_resource.values
      }
    }
  }

}

resource "aws_s3_bucket" "default" {
  count  = var.create_s3_bucket == true ? 1 : 0
  bucket = var.name
  #acl           = "log-delivery-write"
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

resource "aws_s3_bucket_ownership_controls" "default" {
  count  = var.create_s3_bucket == true ? 1 : 0
  bucket = aws_s3_bucket.default[0].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "default" {
  count      = var.create_s3_bucket == true ? 1 : 0
  bucket     = aws_s3_bucket.default[0].id
  acl        = "log-delivery-write"
  depends_on = [aws_s3_bucket_ownership_controls.default]
}

resource "aws_s3_bucket_public_access_block" "default" {
  count                   = var.create_s3_bucket == true ? 1 : 0
  bucket                  = aws_s3_bucket.default[0].id
  block_public_acls       = var.s3_block_public_acls
  block_public_policy     = var.s3_block_public_policy
  ignore_public_acls      = var.s3_ignore_public_acls
  restrict_public_buckets = var.s3_restrict_public_buckets
}

resource "aws_s3_bucket_policy" "default" {
  count  = var.create_s3_bucket == true ? 1 : 0
  bucket = aws_s3_bucket.default[0].id
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

    #condition {
    #  test     = "StringEquals"
    #  variable = "aws:SourceArn"
    #  values   = ["arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${var.name}"]
    #}

    #condition {
    #  test     = "StringEquals"
    #  variable = "aws:SourceAccount"
    #  values   = [data.aws_caller_identity.current.account_id]
    #}
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
    resources = ["${aws_cloudwatch_log_group.cloudtrail[0].arn}:log-stream:*"]

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
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_iam_role_policy" "cloudwatch_logs" {
  count  = var.enable_cloudwatchlogs == true ? 1 : 0
  name   = "cloudwatch-logs"
  policy = data.aws_iam_policy_document.cloudwatch_logs_role[0].json
  role   = aws_iam_role.cloudwatch_logs[0].id
}

resource "aws_iam_role_policy" "cloudwatch_logs_organizations" {
  count  = var.enable_cloudwatchlogs == true && var.is_organization_trail == true ? 1 : 0
  name   = "cloudwatch-logs-organizations"
  policy = data.aws_iam_policy_document.cloudwatch_logs_role_organizations[0].json
  role   = aws_iam_role.cloudwatch_logs[0].id
}

data "aws_iam_policy_document" "cloudwatch_logs_role_organizations" {
  count = var.enable_cloudwatchlogs == true && var.is_organization_trail == true ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream"
    ]
    resources = ["${aws_cloudwatch_log_group.cloudtrail[0].arn}:log-stream:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.cloudtrail[0].arn}:log-stream:*"]
  }
}
