provider "aws" {
  region = "ap-northeast-2"

  # Terraform by default looks at the ~/.aws/credentials file 
  # for the aws access key and secret.
  # The profile config tells which profile credential
  # to look at in the aws credential file.
  profile = "bellti9er"
}

###########################################################
## Remote States
###########################################################
data "terraform_remote_state" "management" {
  backend = "s3"

  config = {
    bucket  = "bellti9er-tf-state-prod"
    key     = "management/vpc.state"
    region  = "ap-northeast-2"
    profile = "bellti9er"
  }
}

###########################################################
## EC2 Instance
###########################################################
resource "aws_instance" "cicd" {
  count                       = local.instance_count
  ami                         = local.ami
  instance_type               = local.instance_type
  key_name                    = local.instance_key_name
  vpc_security_group_ids      = [aws_security_group.cicd.id]
  subnet_id                   = data.terraform_remote_state.management.outputs.public_subnet_ids[0]
  associate_public_ip_address = true
  user_data                   = file("jenkins_init.sh")

  tags = {
    Name = local.name
  }
}

###########################################################
## Security Groups
###########################################################
resource "aws_security_group" "cicd" {
  vpc_id      = data.terraform_remote_state.management.outputs.vpc_id
  name        = local.name
  description = "${local.name} Security Group"

  tags = {
    Name = local.name
  }
}

resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.cicd.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http_ingress" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.cicd.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "all_traffic_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  security_group_id = aws_security_group.cicd.id
  cidr_blocks       = ["0.0.0.0/0"]

  lifecycle {
    create_before_destroy = true
  }
}
