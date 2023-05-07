provider "aws" {
  region  = "us-east-1"
}


resource "aws_vpc" "terraform-vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "terraform-vpc"
  }
}


resource "aws_subnet" "terraform-subnet" {
  vpc_id                  = aws_vpc.terraform-vpc.id 
  cidr_block              = "172.16.1.0/24" 
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-subnet"
  }
}


resource "aws_internet_gateway" "terraform-gw" {
  vpc_id = aws_vpc.terraform-vpc.id 

  tags = {
    Name = "terraform-gw"
  }
}

resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.terraform-vpc.id 

  route {  
    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.terraform-gw.id
  }

  tags = {
   
    Name = "publica-R"

  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.terraform-subnet.id
  route_table_id = aws_route_table.publica.id
}

resource "aws_security_group" "terraform-sg" {
  
  description = "permitir trafico HTTP Y SSH mediante terraform"
  vpc_id = aws_vpc.terraform-vpc.id
 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
   
    Name = "terraform-sg"

  }
}

resource "aws_instance" "nombre-resource" {
  vpc_security_group_ids = [aws_security_group.terraform-sg.id]
  subnet_id              = aws_subnet.terraform-subnet.id
  associate_public_ip_address = true
  ami                    = "ami-02396cdd13e9a1257"
  instance_type          = "t2.micro"
  key_name               = "vockey"
  
  tags = {
    Name = "pruebaEC2"
  }

  connection {
   type = "ssh"
   user = "ec2-user"
   private_key = file("labsuser.pem")
   host = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      
      "sudo yum update -y",
      "sudo yum install httpd -y",
      "sudo systemctl enable httpd",
    
      "sudo yum install git -y",
      "git version",
      "git config --global user.name FedericoG",
      "git config --global user.email fedefrostylol@gmail.com",
      "git config --global color.ui true",
      "git config --global color.status auto",
      "git config --global color.branch auto",
      "git config --global color.editor auto",
      
      "git clone https://github.com/mauricioamendola/chaos-monkey-app.git",
      
      "cd chaos-monkey-app",

      "sudo mv chaos-monkey-app/website/ /var/www/html",
       
      
       

      "sudo systemctl start httpd",


      

    ]
    
  }
}
