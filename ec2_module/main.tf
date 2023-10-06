resource "aws_instance" "ec2" {
  ami           = data.aws_ami.linux_ami.id
  instance_type = var.instance_type
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"

  }
  monitoring    = "true"
  ebs_optimized = "true"

  root_block_device {
    encrypted = "true"
  }
}

