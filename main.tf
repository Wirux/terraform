provider "aws" {
  region     = "eu-central-1"
  shared_credentials_file = "/Users/tf_user/.aws/credentials"
}
resource "aws_instance" "web" {
  ami           = "ami-05f7491af5eef733a"
  instance_type = "t2.micro"

  tags = {
    Name = "changeKey"
  }
}
