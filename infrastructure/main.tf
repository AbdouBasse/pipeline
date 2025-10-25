# 🔧 Provider AWS
provider "aws" {
  region = var.region  
}

# 🌐 VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr  # Ex: "10.0.0.0/16"
  tags = {
    Name = "FilRouge-VPC"
  }
}

# 🧩 Subnet public
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr  # Ex: "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "FilRouge-Subnet"
  }
}

# 🌐 Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "FilRouge-Gateway"
  }
}

# 📡 Table de routage
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "FilRouge-RouteTable"
  }
}

# 🔗 Association du subnet à la table de routage
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# 🔐 Groupe de sécurité
resource "aws_security_group" "web_sg" {
  name        = "FilRouge-SG"
  description = "Autorise SSH et HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
    Name = "FilRouge-SG"
  }
}

# 💻 EC2 avec rôle LabInstanceProfile
resource "aws_instance" "web" {
  ami                    = var.ami_id         # Ex: Amazon Linux 2
  instance_type          = var.instance_type  # Ex: "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  iam_instance_profile   = "LabInstanceProfile"  # Respecte les restrictions du sandbox

  tags = {
    Name = "FilRouge-EC2"
  }
}

# 🗄️ Base de données RDS (si ton app en a besoin)
resource "aws_db_instance" "db" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  username             = var.db_user
  password             = var.db_pass
  skip_final_snapshot  = true
  publicly_accessible  = true
  identifier           = "filrouge-db"
  engine_version       = "8.0
  parameter_group_name = "default.mysql8.0"


  tags = {
    Name = "FilRouge-DB"
  }
}
