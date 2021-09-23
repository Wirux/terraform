/*
Working ssh.
*/

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region                  = "eu-central-1"
  shared_credentials_file = "/Users/tf_user/.aws/credentials"
}
resource "aws_instance" "main" {
  ami           = "ami-05f7491af5eef733a"
  instance_type = "t2.micro"
  key_name      = "Main"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.main.id
  }
  user_data = file("userdata.sh")
  tags = {
    Name = "vpc"
  }
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnets[0].ip

  tags = {
    Name = var.subnets[0].name
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
      cidr_block                 = "0.0.0.0/0"
      egress_only_gateway_id     = ""
      gateway_id                 = aws_internet_gateway.gw.id
      instance_id                = ""
      ipv6_cidr_block            = ""
      nat_gateway_id             = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_peering_connection_id  = ""
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      local_gateway_id           = ""
      vpc_endpoint_id            = ""


    },
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
  description = "Allow web traffics"
  vpc_id      = aws_vpc.main.id

  ingress = [

    {
      description      = "HTTPS"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },

    {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]


  egress = [
    {
      description      = "rest"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "main"
  }
}

resource "aws_network_interface" "main" {
  subnet_id       = aws_subnet.main.id
  private_ips     = [var.eip]
  security_groups = [aws_security_group.main.id]

}

resource "aws_eip" "main" {
  vpc                       = true
  network_interface         = aws_network_interface.main.id
  associate_with_private_ip = var.eip
  depends_on = [aws_internet_gateway.gw,
                aws_instance.main]
}

output "pubip" {
  value       = aws_eip.main.public_ip
  sensitive   = false
  description = "Public server IP"
  depends_on  = []
}

variable eip {
  description = "eip"
}
variable vpc_cidr {
  description = "vpc_cidr"
}
variable subnets {
  description = "description"
}
