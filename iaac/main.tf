terraform {
  required_version = ">= 1.2.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.20.1"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "2.17.0"
    }
  }
}

provider aws {
  region  = "us-east-1"
  profile = "go-example"

  default_tags {
    tags = {
      project: "go-example"
    }
  }
}

data aws_ecr_authorization_token go_server {
  registry_id = aws_ecr_repository.go_server.registry_id
}

provider docker {
  registry_auth {
    address  = split("/", local.ecr_url)[0]
    username = data.aws_ecr_authorization_token.go_server.user_name
    password = data.aws_ecr_authorization_token.go_server.password
  }
}
