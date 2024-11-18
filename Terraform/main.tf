terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

# Data block to fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch subnets in the default VPC using the filter argument
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# Create an AWS key pair and store the private key locally
resource "aws_key_pair" "my_key_pair" {
  key_name   = "my-key-pair"
  public_key = file("~/.ssh/id_rsa.pub") # Replace this with the path to an existing public key if available
}

# Create Security Groups
resource "aws_security_group" "normal_SG" {
  name   = "normal_SG"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Outbound (egress) rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 allows all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "k8s_SG" {
  name   = "k8s_SG"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Outbound (egress) rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 allows all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Define instances
resource "aws_instance" "jenkins" {
  ami             = "ami-0583d8c7a9c35822c" # Replace with your RedHat AMI ID
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.my_key_pair.key_name
  security_groups = [aws_security_group.normal_SG.name]

  tags = {
    Name = "Jenkins"
  }
}

resource "aws_instance" "ansible" {
  ami             = "ami-0583d8c7a9c35822c" # Replace with your RedHat AMI ID
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.my_key_pair.key_name
  security_groups = [aws_security_group.normal_SG.name]

  tags = {
    Name = "Ansible"
  }
}

resource "aws_instance" "Monotoring" {
  ami             = "ami-0583d8c7a9c35822c" # Replace with your RedHat AMI ID
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.my_key_pair.key_name
  security_groups = [aws_security_group.normal_SG.name]

  tags = {
    Name = "Monotoring"
  }
}

resource "aws_instance" "k8s_master" {
  ami             = "ami-0583d8c7a9c35822c" # Replace with your RedHat AMI ID
  instance_type   = "t2.medium"
  key_name        = aws_key_pair.my_key_pair.key_name
  security_groups = [aws_security_group.k8s_SG.name]

  tags = {
    Name = "K8sMaster"
  }
}

resource "aws_instance" "k8s_worker1" {
  ami             = "ami-0583d8c7a9c35822c" # Replace with your RedHat AMI ID
  instance_type   = "t2.medium"
  key_name        = aws_key_pair.my_key_pair.key_name
  security_groups = [aws_security_group.k8s_SG.name]

  tags = {
    Name = "K8sWorker1"
  }
}

resource "aws_instance" "k8s_worker2" {
  ami             = "ami-0583d8c7a9c35822c" # Replace with your RedHat AMI ID
  instance_type   = "t2.medium"
  key_name        = aws_key_pair.my_key_pair.key_name
  security_groups = [aws_security_group.k8s_SG.name]

  tags = {
    Name = "K8sWorker2"
  }
}


# Optional: Output IPs for easier SSH access
output "instance_ips" {
  value = {
    jenkins            = aws_instance.jenkins.public_ip
    ansible            = aws_instance.ansible.public_ip
    Monotoring = aws_instance.Monotoring.public_ip
    k8s_master         = aws_instance.k8s_master.public_ip
    k8s_worker1        = aws_instance.k8s_worker1.public_ip
    k8s_worker2        = aws_instance.k8s_worker2.public_ip
  }
}