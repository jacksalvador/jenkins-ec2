resource "aws_vpc" "vpc_yang" {
  cidr_block       = "10.0.1.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "VPC-YANG"
  }
}

resource "aws_subnet" "sbn_yang_public1" {
  vpc_id     = aws_vpc.vpc_yang.id
  cidr_block = "10.0.1.0/27"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "SBN-YANG-PUBLIC1"
  }
}

resource "aws_subnet" "sbn_yang_public2" {
  vpc_id     = aws_vpc.vpc_yang.id
  cidr_block = "10.0.1.32/27"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "SBN-YANG-PUBLIC2"
  }
}

resource "aws_subnet" "sbn_yang_private1" {
  vpc_id     = aws_vpc.vpc_yang.id
  cidr_block = "10.0.1.64/27"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "SBN-YANG-PRIVATE2"
  }
}

resource "aws_subnet" "sbn_yang_private2" {
  vpc_id     = aws_vpc.vpc_yang.id
  cidr_block = "10.0.1.96/27"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "SBN-YANG-PRIVATE2"
  }
}

resource "aws_internet_gateway" "igw_yang" {
  vpc_id = aws_vpc.vpc_yang.id

  tags = {
    Name = "IGW-YANG"
  }
}

resource "aws_route_table" "rt_yang_public" {
  vpc_id = aws_vpc.vpc_yang.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_yang.id
  }

  tags = {
    Name = "RT-YANG-PUBLIC"
  }
}

resource "aws_route_table_association" "sbn_associations_yang_public1" {
  subnet_id      = aws_subnet.sbn_yang_public1.id
  route_table_id = aws_route_table.rt_yang_public.id
}

resource "aws_route_table_association" "sbn_associations_yang_public2" {
  subnet_id      = aws_subnet.sbn_yang_public2.id
  route_table_id = aws_route_table.rt_yang_public.id
}

# resource "aws_route_table_association" "sbn_associations_yang_private1" {
#   subnet_id      = aws_subnet.sbn_yang_private1.id
#   route_table_id = aws_route_table.rt_yang_private.id
# }

# resource "aws_route_table_association" "sbn_associations_yang_private2" {
#   subnet_id      = aws_subnet.sbn_yang_private2.id
#   route_table_id = aws_route_table.rt_yang_private.id
# }
