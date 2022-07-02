// aws network configuration

resource aws_vpc main {
  cidr_block = "10.0.0.0/20"
}

resource aws_internet_gateway gateway {
  vpc_id = aws_vpc.main.id
}

resource aws_route_table public {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}

resource aws_subnet main {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
}

resource aws_main_route_table_association main {
  route_table_id = aws_route_table.public.id
  vpc_id         = aws_vpc.main.id
}

resource aws_route_table_association main {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}

resource aws_security_group public {
  name = "public-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = local.application_port
    to_port   = local.application_port
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource aws_default_network_acl main {
  default_network_acl_id = aws_vpc.main.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

resource aws_network_acl_association main {
  network_acl_id = aws_default_network_acl.main.id
  subnet_id = aws_subnet.main.id
}
