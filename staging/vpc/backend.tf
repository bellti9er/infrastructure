terraform {
  backend "s3" {
    bucket  = "bellti9er-tf-state-prod"
    key     = "staging/vpc.state"
    region  = "ap-northeast-2"
    profile = "bellti9er"
  }
}
