locals {
  service_name     = "go-example"
  application_port = "80"
  application_internal_port = "80"

  ecr_url = replace(aws_ecr_repository.go_server.repository_url, "https://", "")
}
