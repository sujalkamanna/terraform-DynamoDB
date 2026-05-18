# VPC

resource "aws_vpc" "vpc1" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "VPC1"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "IGW for VPC1"
  }
}

# Public Subnet

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.public_az
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet A"
  }
}
 
# Private Subnet
 
resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.private_az

  tags = {
    Name = "Private Subnet B"
  }
}

# Elastic IP

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "NAT EIP"
  }
}

# NAT Gateway

resource "aws_nat_gateway" "nat_vpc1" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_a.id

  tags = {
    Name = "NAT Gateway for VPC1"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Public Route Table

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Private Route Table

resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_vpc1.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

# Route Table Associations

resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "private_subnet_assoc" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.route_table_private.id
}

# Public Security Group

resource "aws_security_group" "sg_public" {
  name        = "public-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Public SG"
  }
}

# Private Security Group

resource "aws_security_group" "sg_private" {
  name        = "private-sg"
  description = "Allow SSH from Public Subnet"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    description = "SSH from Public Subnet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Private SG"
  }
}

# Public EC2

resource "aws_instance" "public_ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.sg_public.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name = "Public EC2"
  }
}

# Private EC2

resource "aws_instance" "private_ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private_subnet_b.id
  vpc_security_group_ids      = [aws_security_group.sg_private.id]
  associate_public_ip_address = false
  key_name                    = var.key_name

  tags = {
    Name = "Private EC2"
  }
}

# Outputs

output "public_ec2_public_ip" {
  value = aws_instance.public_ec2.public_ip
}

output "private_ec2_private_ip" {
  value = aws_instance.private_ec2.private_ip
}