resource "aws_security_group" "sg_yang_jenkins" {
  name        = "SG-YANG-JENKINS"
  description = "Allow SSH Access from my pc"
  vpc_id      = aws_vpc.vpc_yang.id

  ingress {
    description = "SSH Access from My IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["59.9.142.0/24", "59.15.102.0/24"]
  }

  ingress {
    description = "Web Access from My IP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["59.9.142.0/24", "59.15.102.0/24"]
  }

  ingress {
    description = "Ping test from My IP"
    from_port   = "-1"
    to_port     = "-1"
    protocol    = "icmp"
    cidr_blocks = ["59.9.142.0/24", "59.15.102.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-YANG-JENKINS"
  }
}

resource "aws_security_group" "sg_yang_web" {
  name        = "SG-YANG-WEB"
  description = "Allow SSH Access from my pc"
  vpc_id      = aws_vpc.vpc_yang.id

  ingress {
    description = "SSH Access from My IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["59.9.142.0/24"]
  }

  ingress {
    description = "SSH Access from My IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    description = "Web Access from My IP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["59.9.142.0/24"]
  }

  ingress {
    description = "Ping test from My IP"
    from_port   = "-1"
    to_port     = "-1"
    protocol    = "icmp"
    cidr_blocks = ["59.9.142.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-YANG-WEB"
  }
}
