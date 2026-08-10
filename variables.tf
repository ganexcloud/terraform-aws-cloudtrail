variable "name" {
  description = "(Required) Specifies the name of the trail."
  type        = string
}

variable "tags" {
  description = "(Optional) A map of tags to assign to the trail."
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
  description = "(Optional) Specifies whether the trail is an AWS Organizations trail."
  type        = bool
  default     = false
}

variable "include_global_service_events" {
  description = "(Optional) Specifies whether the trail publishes events from global services."
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "(Optional) Enables logging for the trail."
  type        = bool
  default     = true
}

variable "enable_cloudwatchlogs" {
  description = "(Required) Enables log delivery to CloudWatch Logs."
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Number of days to keep AWS logs in the CloudWatch Logs group."
  type        = string
  default     = 180
}

variable "event_selector" {
  description = "(Optional) Specifies event selectors for enabling data event logging."
  type = list(object({
    include_management_events = bool
    read_write_type           = string
    data_resource = object({
      type   = string
      values = list(string)
    })
  }))
  default = []
}

variable "kms_key_id" {
  description = "(Optional) Specifies the KMS key ARN used to encrypt CloudTrail logs."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "A boolean indicating whether all objects can be deleted when destroying the bucket."
  type        = string
  default     = false
}

variable "create_s3_bucket" {
  description = "(Optional) Automatically creates the S3 bucket for CloudTrail."
  type        = bool
  default     = true
}

variable "s3_bucket_name" {
  description = "(Optional) Required when create_s3_bucket is false, the existing S3 bucket name."
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

variable "s3_lifecycle_expiration_days" {
  description = "Days until objects in the bucket expire."
  type        = number
  default     = 1825
}
