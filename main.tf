provider "aws" {
  region     = "eu-central-1"
  shared_credentials_file = "/Users/tf_user/.aws/credentials"
}
resource "aws_instance" "main" {
  ami           = "ami-05f7491af5eef733a"
  instance_type = "t2.micro"
  key_name = "main"
  network_interface {
     device_index         = 0
     network_interface_id = aws_network_interface.main.id
   }
  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo your very first web server > /var/www/html/index.html'
                EOF

  tags = {
    Name = "changeKey"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route = [
    {
      cidr_block = "10.0.1.0/24"
      gateway_id = aws_internet_gateway.gw.id
    },
    {
      ipv6_cidr_block        = "::/0"
      egress_only_gateway_id = aws_egress_only_internet_gateway.main.id
    }
  ]

  tags = {
    Name = "example"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "main" {
  name        = "main"
  description = "Allow TLS and SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress = [
    {
      description      = "TLS from VPC"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
    }
  ]

#  ingress = [
#    {
#      description      = "SSH from VPC"
#      from_port        = 22
#      to_port          = 22
#      protocol         = "tcp"
#      cidr_blocks      = ["0.0.0.0/0"]
#      ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
#    }
#  ]


#  egress = [
#    {
#      from_port        = 0
#      to_port          = 0
#      protocol         = "-1"
#      cidr_blocks      = ["0.0.0.0/0"]
#      ipv6_cidr_blocks = ["::/0"]
#    }
#  ]

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_network_interface" "main" {
  subnet_id       = aws_subnet.main.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.main.id]

}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.main.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
}