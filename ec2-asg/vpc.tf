resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "ASG VPC"
  }
}

resource "aws_subnet" "public_subnet-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "Public subnet 1"
  }
}

resource "aws_subnet" "public_subnet-2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name = "Public subnet 2"
  }
}

resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main VPC IGW"
  }
}

resource "aws_route_table" "route-table-1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-igw.id
  }
  tags = {
   Name = "Public Subnet Route Table" 
  }
}

resource "aws_route_table_association" "route-table-association-1" {
  subnet_id = aws_subnet.public_subnet-1.id
  route_table_id = aws_route_table.route-table-1.id
}

resource "aws_route_table_association" "route-table-association-2" {
  subnet_id = aws_subnet.public_subnet-2.id
  route_table_id = aws_route_table.route-table-1.id
  
}