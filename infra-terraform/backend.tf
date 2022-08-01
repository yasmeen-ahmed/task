terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

  }




  backend "s3" {
    bucket         = "backendterra"
    key            = "terraform-aws.tfstate"
    region         = "us-east-1"
    #profile        = "task"
  }
}
