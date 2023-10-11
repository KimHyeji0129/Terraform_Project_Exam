terraform {
  backend "s3" {
    bucket         = "myterraform-bucket-state-khj-t"
    key            = "stage/app1/terraform.tfstate"
    region         = "ap-northeast-2"
    profile        = "terraform_user"
    dynamodb_table = "myTerraform-bucket-lock-khj-t"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
  profile = "terraform_user"
}

module "stage_alb" {
  source           = "../../modules/aws_alb"
  name             = "stage"
  vpc_id           = data.terraform_remote_state.vpc_remote_data.outputs.vpc_id
  public_subnets   = data.terraform_remote_state.vpc_remote_data.outputs.public_subnets
  HTTP_HTTPS_SG_ID = data.terraform_remote_state.vpc_remote_data.outputs.HTTP_HTTPS_SG
}

output "ALB_TG" {
  value       = module.stage_alb.ALB_TG
  description = "Load Balancer Target Group ARN"
}

output "ALB_DNS" {
  value       = module.stage_alb.ALB_DNS
  description = "Load Balancer Domain Name"
}

module "stage_asg" {
  source           = "../../modules/aws_asg"
  instance_type    = "t2.micro"
  min_size         = "1"
  max_size         = "1"
  name             = "stage"
  private_subnets  = data.terraform_remote_state.vpc_remote_data.outputs.private_subnets
  SSH_SG_ID        = data.terraform_remote_state.vpc_remote_data.outputs.SSH_SG
  HTTP_HTTPS_SG_ID = data.terraform_remote_state.vpc_remote_data.outputs.HTTP_HTTPS_SG
}