output "vpc_id" { value = aws_vpc.this.id }
output "public_subnet_ids" { value = [aws_subnet.public1.id, aws_subnet.public2.id] }

resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "next-app-vpc"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.ap-southeast-5.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "next-app-vpce-s3"
  }
}

resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.0.0/20"
  availability_zone = "ap-southeast-5a"

  tags = {
    Name = "next-app-subnet-public1-ap-southeast-5a"
  }
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = "ap-southeast-5b"

  tags = {
    Name = "next-app-subnet-public2-ap-southeast-5b"
  }
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.128.0/20"
  availability_zone = "ap-southeast-5a"

  tags = {
    Name = "next-app-subnet-private1-ap-southeast-5a"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.144.0/20"
  availability_zone = "ap-southeast-5b"

  tags = {
    Name = "next-app-subnet-private2-ap-southeast-5b"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "next-app-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "next-app-rtb-public"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "next-app-eip-ap-southeast-5a"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "next-app-nat-public1-ap-southeast-5a"
  }
}

resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "next-app-rtb-private1-ap-southeast-5a"
  }
}

resource "aws_route" "private1_nat" {
  route_table_id         = aws_route_table.private1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "private1_assoc" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private1.id
}

resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "next-app-rtb-private2-ap-southeast-5b"
  }
}

resource "aws_route" "private2_nat" {
  route_table_id         = aws_route_table.private2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "private2_assoc" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private2.id
}

resource "aws_vpc_endpoint_route_table_association" "vpce_private1" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.private1.id
}

resource "aws_vpc_endpoint_route_table_association" "vpce_private2" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.private2.id
}

