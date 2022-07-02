// set up ecr repository with docker upload and ec2 instance

resource aws_ecr_repository go_server {
  name = local.service_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

data aws_iam_policy_document ecr_policy {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "*"
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy"
    ]
  }
}

resource aws_ecr_repository_policy go_server {
  repository = aws_ecr_repository.go_server.name
  policy = data.aws_iam_policy_document.ecr_policy.json
}

data aws_ami ubuntu {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource aws_instance application {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.public.id]
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.profile.name

  user_data = <<EOF
#!/bin/bash
echo "step 1" >> step1.txt
sudo apt-get update
sudo apt-get install -y pt-transport-https ca-certificates curl gnupg lsb-release software-properties-common
echo "step 2" >> step2.txt
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu `lsb_release -cs` test"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo gpasswd -a $USER docker
newgrp docker

echo "step 3" >> step3.txt

sudo echo "${data.aws_ecr_authorization_token.go_server.password}" >> pass.txt
sudo echo "${data.aws_ecr_authorization_token.go_server.user_name}" >> user.txt
sudo echo "${aws_ecr_repository.go_server.repository_url}" >> url.txt
sudo echo "${docker_registry_image.go_example.name}" >> docker.txt

echo "step 4" >> step4.txt

echo ${data.aws_ecr_authorization_token.go_server.password} | docker login --username=${data.aws_ecr_authorization_token.go_server.user_name} --password-stdin ${aws_ecr_repository.go_server.repository_url}

docker run -p ${local.application_port}:${local.application_internal_port} -d --restart always ${docker_registry_image.go_example.name}

echo "step 5" >> step5.txt
EOF

  depends_on = [aws_internet_gateway.gateway]
}

output application_ip {
  value       = aws_instance.application.public_ip
  description = "Application public IP"
}
