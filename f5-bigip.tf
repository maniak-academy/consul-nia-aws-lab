resource "random_string" "password" {
  //count = var.f5_password == null ? 1 : 0
  length      = 16
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  special     = false
}

data "template_file" "f5_init" {
  template = file("./scripts/f5.tpl")

  vars = {
    encrypted_password = random_string.password.result
  }
}


module "bigip" {
  count                  = 1
  source                 = "F5Networks/bigip-module/aws"
#  prefix                 = "${var.prefix}-f5-bigip"
  prefix                 = "bigip-aws-1nic"
  ec2_instance_type      = "m5.large"
  ec2_key_name           = aws_key_pair.demo.key_name
  f5_ami_search_name     = var.f5_ami_search_name
  f5_username            = var.f5_username
  f5_password            = random_string.password.result
  mgmt_subnet_ids        = [{ "subnet_id" = module.vpc.public_subnets[0], "public_ip" = true, "private_ip_primary" = "10.0.0.200" }]
  mgmt_securitygroup_ids = [aws_security_group.f5.id]
  custom_user_data       = data.template_file.f5_init.rendered
}
