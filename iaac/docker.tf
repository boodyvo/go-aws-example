# manage docker image to upload to ecr

data aws_ecr_authorization_token go_server {
  registry_id = aws_ecr_repository.go_server.registry_id
}

resource docker_registry_image go_example {
  name = "${local.ecr_url}:v1"

  build {
    context    = "${path.module}/../app/."
    dockerfile = "app/Dockerfile"
    no_cache   = true
  }

  depends_on = [aws_ecr_repository.go_server]
}
