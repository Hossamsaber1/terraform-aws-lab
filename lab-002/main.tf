# -----------------------
# VPC
# -----------------------
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "${terraform.workspace}-vpc"
    Environment = terraform.workspace
  }
}

# -----------------------
# Internet Gateway
# -----------------------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${terraform.workspace}-igw"
    Environment = terraform.workspace
  }
}

# -----------------------
# Subnets using for_each
# -----------------------
/*
resource "aws_subnet" "subnets" {
  for_each = var.subnets

  vpc_id     = aws_vpc.main.id
  cidr_block = each.value.cidr

  map_public_ip_on_launch = each.value.type == "public" ? true : false

  tags = {
    Name        = "${terraform.workspace}-${each.key}-subnet"
    Type        = each.value.type
    Environment = terraform.workspace
  }
}
*/
# -----------------------
# Public Route Table
# -----------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${terraform.workspace}-public-rt"
    Environment = terraform.workspace
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.subnets["public"].id
  route_table_id = aws_route_table.public.id
}

# -----------------------
# Security Groups
# -----------------------
resource "aws_security_group" "bastion_sg" {
  name        = "${terraform.workspace}-bastion-sg"
  description = "Allow SSH from anywhere"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
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
    Name        = "${terraform.workspace}-bastion-sg"
    Environment = terraform.workspace
  }
}

resource "aws_security_group" "app_sg" {
  name        = "${terraform.workspace}-app-sg"
  description = "Allow SSH and app port from VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "App port 3000 from VPC"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${terraform.workspace}-app-sg"
    Environment = terraform.workspace
  }
}

# -----------------------
# EC2 Instances using count
# count.index == 0 => bastion in public subnet
# count.index == 1 => app in private subnet
# -----------------------
resource "aws_instance" "servers" {
  count = length(var.instance_names)

  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = count.index == 0 ? aws_subnet.subnets["public"].id : aws_subnet.subnets["private"].id

  vpc_security_group_ids = count.index == 0 ? [aws_security_group.bastion_sg.id] : [aws_security_group.app_sg.id]

  tags = {
    Name        = "${terraform.workspace}-${var.instance_names[count.index]}"
    Environment = terraform.workspace
  }

  provisioner "local-exec" {
    command = count.index == 0 ? "echo Bastion Public IP: ${self.public_ip}" : "echo Private App Created"
  }
}