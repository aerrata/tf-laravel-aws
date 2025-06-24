terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-southeast-5"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0f9d1a7c9b7629f3f"
  instance_type = "t4g.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}
