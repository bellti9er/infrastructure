###########################################################
## Local Vars
###########################################################
locals {
  name              = "CICD"
  ami               = "ami-06e7b9c5e0c4dd014"
  instance_type     = "t2.micro"
  instance_key_name = "cicd"
  instance_count    = 1
}
