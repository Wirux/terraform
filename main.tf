provider "aws" {
  region     = "eu-central-1"
  access_key = "AKIAUMHIZWBQ2PYHFBDE"
  secret_key = "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"

}

resource "aws_instance" "web" {
  ami           = "ami-05f7491af5eef733a"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}
