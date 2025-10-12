resource "aws_vpc" "main" {
  cidr_block  = "10.1.0.0/16"
  tags        = { Name = "terraform-vpc" }
}


resource "aws_subnet" "public" {
  vpc_id  = aws_vpc.main.id
  cidr_block = "10.1.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = { Name = "terraform-subnet" }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "terraform-igw" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "terraform-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and SSH inbound"
  vpc_id      = aws_vpc.main.id
  

  ingress {
    description ="Allow HTTP"
    from_port = 80
    to_port = 80
    protocol ="tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port = 22
    to_port = 22
    protocol ="tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port =0
    to_port =0
    protocol="-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name  = " terraform-web-sg" }
}


resource "aws_instance" "web" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids= [aws_security_group.web_sg.id ]
  key_name = var.key_name


  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1> Hello from Terraform Web Server </h1>" > /var/www/html/index.html
              EOF

  tags = { Name = "terraform-web-server" }
}
              


