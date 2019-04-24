variable "name" {
  description = "Name"
  type        = "string"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. map('BusinessUnit`,`XYZ`)"
}

variable "enable_log_file_validation" {
  default     = "true"
  description = "Specifies whether log file integrity validation is enabled. Creates signed digest for validated contents of logs"
}

variable "is_multi_region_trail" {
  default     = "true"
  description = "Specifies whether the trail is created in the current region or in all regions"
}

variable "include_global_service_events" {
  default     = "true"
  description = "Specifies whether the trail is publishing events from global services such as IAM to the log files"
}

variable "enable_logging" {
  default     = "true"
  description = "Enable logging for the trail"
}

variable "cloud_watch_logs_role_arn" {
  description = "Specifies the role for the CloudWatch Logs endpoint to assume to write to a user’s log group"
  default     = ""
}

variable "cloud_watch_logs_group_arn" {
  description = "Specifies a log group name using an Amazon Resource Name (ARN), that represents the log group to which CloudTrail logs will be delivered"
  default     = ""
}

variable "event_selector" {
  type        = "list"
  description = "Specifies an event selector for enabling data event logging, It needs to be a list of map values. See: https://www.terraform.io/docs/providers/aws/r/cloudtrail.html for details on this map variable"
  default     = []
}

variable "kms_key_id" {
  description = "Specifies the KMS key ARN to use to encrypt the logs delivered by CloudTrail"
  default     = ""
}

variable "versioning_enabled" {
  default     = true
  type        = "string"
  description = "Enable versioning. Versioning is a means of keeping multiple variants of an object in the same bucket."
}

variable "force_destroy" {
  default     = false
  type        = "string"
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error."
}
