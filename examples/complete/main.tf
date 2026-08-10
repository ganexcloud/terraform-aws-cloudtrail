terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40.0, < 7.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "cloudtrail" {
  source = "../.."

  name                  = "example-cloudtrail"
  enable_cloudwatchlogs = true
  is_organization_trail = true
  event_selector = [{
    include_management_events = true
    read_write_type           = "All"
    data_resource = {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::example-cloudtrail/AWSLogs/"]
    }
  }]
}
