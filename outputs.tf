output "cloudtrail_id" {
  description = "The name of the trail."
  value       = aws_cloudtrail.default.id
}

output "cloudtrail_home_region" {
  description = "The region in which the trail was created."
  value       = aws_cloudtrail.default.home_region
}

output "cloudtrail_arn" {
  description = "The Amazon Resource Name of the trail."
  value       = aws_cloudtrail.default.arn
}

output "cloudwatch_log_group_name" {
  description = "The CloudWatch Logs group name."
  value       = join("", aws_cloudwatch_log_group.cloudtrail[*].name)
}
