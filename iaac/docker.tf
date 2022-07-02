# manage docker image to upload to ecr

resource docker_registry_image go_example {
  name = "${local.ecr_url}:v1"

  build {
    context    = "${path.module}/../app/."
    dockerfile = "app/Dockerfile"
    no_cache   = true
  }

  depends_on = [aws_ecr_repository.go_server]
}
