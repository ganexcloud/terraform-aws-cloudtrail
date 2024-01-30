variable "name" {
  description = "(Required) Specifies the name of the trail."
  type        = string
}

variable "tags" {
  description = "(Optional) A map of tags to assign to the trail"
  type        = map(string)
  default     = {}
}

variable "enable_log_file_validation" {
  description = "(Optional) Specifies whether log file integrity validation is enabled."
  type        = bool
  default     = true
}

variable "is_multi_region_trail" {
  description = "(Optional) Specifies whether the trail is created in the current region or in all regions."
  type        = bool
  default     = true
}

variable "is_organization_trail" {
  description = "(Optional) Specifies whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account. "
  type        = bool
  default     = false
}

variable "include_global_service_events" {
  description = "(Optional) Specifies whether the trail is publishing events from global services such as IAM to the log files. "
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "(Optional) Enables logging for the trail."
  type        = bool
  default     = true
}

variable "enable_cloudwatchlogs" {
  description = "(Required) Enable log delivery to CloudWatchLogs"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Number of days to keep AWS logs around in specific log group on CloudwatchLogs."
  type        = string
  default     = 180
}

variable "event_selector" {
  description = "(Optional) Specifies an event selector for enabling data event logging. "
  type        = list(string)
  default     = []
}

variable "kms_key_id" {
  description = "(Optional) Specifies the KMS key ARN to use to encrypt the logs delivered by CloudTrail."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error."
  type        = string
  default     = false
}

variable "create_s3_bucket" {
  description = "(Optional) Automatically create the s3 bucket to cloudtrail."
  type        = bool
  default     = true
}

variable "s3_bucket_name" {
  description = "(Optional) Required if create_s3_bucket is false, the name of S3 bucket."
  type        = string
  default     = null
}


variable "s3_block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "s3_block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "s3_ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "s3_restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = true
}