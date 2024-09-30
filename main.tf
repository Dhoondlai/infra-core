resource "aws_vpc" "main-vpc" {
  cidr_block = "10.0.0.0/16"
}

# Subnets

resource "aws_subnet" "main-public-subnet-1" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "main-private-subnet-1" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
}

# Internet gateway

resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.main-vpc.id
}


# Route table

resource "aws_route_table" "main-public-rt" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.main-igw.id
  }
}

resource "aws_route_table_association" "public_1_rt_a" {
  subnet_id      = aws_subnet.main-public-subnet-1.id
  route_table_id = aws_route_table.main-public-rt.id
}

# Security group

resource "aws_security_group" "main-vpc-web-sg" {
  name   = "main-vpc-web-sg"
  vpc_id = aws_vpc.main-vpc.id
}
