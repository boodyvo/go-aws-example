// iam ec2 role setup

data aws_iam_policy_document assume_role_ec2_policy_document {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource aws_iam_role role {
  name               = "application-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2_policy_document.json
}

data aws_iam_policy_document ecr_access_policy_document {
  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
    ]

    resources = ["*"]
  }
}

resource aws_iam_policy ecr_access_policy {
  name = "ecr-access-policy"
  policy = data.aws_iam_policy_document.ecr_access_policy_document.json
}

resource aws_iam_policy_attachment ecr_access {
  name       = "ecr-access"
  roles      = [aws_iam_role.role.name]
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}

resource aws_iam_instance_profile profile {
  name = "application-ec2-profile"
  role = aws_iam_role.role.name
}
