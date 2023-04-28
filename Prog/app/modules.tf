provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAYKVU2WOBZETTP7FO"
  secret_key = "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"
}

#####################################

variable "instance_type" {
  type        = string
  default     = "t2.micro"
}

variable "ebs_size" {
  type        = number
  default     = 8
}

variable "tags" {
  type        = map(string)
  default     = {}
}
##########################################

data "aws_ami" "ubuntu_bionic" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "ec2_instance" {
  ami           = data.aws_ami.ubuntu_bionic.id
  instance_type = var.instance_type
  tags          = var.tags

  root_block_device {
    volume_size = var.ebs_size
    volume_type = "gp2"
    delete_on_termination = true
  }

  associate_public_ip_address = true
}

resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = aws_instance.ec2_instance.availability_zone
  size              = var.ebs_size
  tags              = var.tags
}

resource "aws_volume_attachment" "ebs_attachment" {
  device_name = "/dev/sdv"
  volume_id   = aws_ebs_volume.ebs_volume.id
  instance_id = aws_instance.ec2_instance.id
}

###############################################################

variable "size" {
  type        = number
  default     = 8
}

variable "tags" {
  type        = map(string)
  default     = {}
}

resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = var.availability_zone
  size              = var.size
  tags              = var.tags
}

################################################

variable "instance_id" {
  description = "ID de l'instance EC2 à associer à l'IP publique"
  type        = string
}

variable "security_group_id" {
  description = "ID du groupe de sécurité à associer à l'IP publique"
  type        = string
}

resource "aws_eip" "public_ip" {
  instance = var.instance_id
  vpc      = true

  tags = {
    Name = "Public IP"
  }
}

resource "aws_security_group_rule" "public_ip_sg_rule" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "icmp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = var.security_group_id
}

resource "aws_network_interface_attachment" "eni_attachment" {
  instance_id          = var.instance_id
  network_interface_id = aws_eip.public_ip.network_interface_id
}


