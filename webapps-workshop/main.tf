provider "aws" {
  shared_credentials_files = ["$HOME/.aws/credentials"]
  region                   = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch =  true
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public Subnet 0"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch =  false
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private Subnet 0"
  }
 } 

 resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "My VPC - Internet Gateway"
  }
 }

resource "aws_route_table" "my_vpc_us_east_1a_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_vpc_igw.id
  }
  tags = {
    "Name" = "Public Subnet Route Table"
  }
}

resource "aws_route_table_association" "my_vpc_us_east_1a_public" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.my_vpc_us_east_1a_public.id
}

resource "aws_security_group" "allow_ssh_sg" {
  name        = "allow_ssh_sg"
  description = "Allow SSH inbound connections"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port = 80
    to_port   = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port = 0
    to_port =  0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

 tags = {
  Name = "allow_ssh_sg"
 } 
}

resource "aws_security_group" "rds-sg" {
  name = "rds-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.allow_ssh_sg.id]

  }
  egress {
    from_port = 0
    to_port   = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }  

}

resource "aws_instance" "my_instance" {
  ami           = "ami-0cff7528ff583bf9a"
  instance_type = "t2.micro"
  key_name = "ec2-key"
  vpc_security_group_ids = [ aws_security_group.allow_ssh_sg.id ]
  subnet_id = aws_subnet.public_subnet.id 
  associate_public_ip_address = true

  tags = {
    "Name" = "My Instance"
  }
}

resource "aws_db_subnet_group" "my-db-subnet" {
  name = "my-db-subnet"
  subnet_ids = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
  
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name              = "mydb"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.my-db-subnet.id
  vpc_security_group_ids = [ aws_security_group.rds-sg.id ]
  
}

output "instance_public_ip" {
  value = "${aws_instance.my_instance.public_ip}"
}

output "Endpoint_string" {
  value = "${aws_db_instance.default.endpoint}"
  
}