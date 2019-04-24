module "cloudtrail-NAME" {
  source = "git::https://gitlab.com/ganex-cloud/terraform/terraform-aws-cloudtrail.git?ref=master"
  name   = "NAME.cloudtrail"
}
