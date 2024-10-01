resource "tls_private_key" "db-private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "db-key-pair" {
  key_name   = "backend-dhoondlai-key-pair"
  public_key = tls_private_key.db-private-key.public_key_openssh
}

data "aws_ami" "mongodb-ubuntu" {
  owners = ["self"]
  filter {
    name   = "name"
    values = ["mongodb-ubuntu-22"]
  }
}

# we can't use a private subnet. As we will have to :
# 1- Attach a NAT in order to use SSM
# 2- Use a bastion host if not using SSM
# Both of these options are too much cost for us.

# See : https://github.com/Dhoondlai/mongodb-ami documentation for next steps after ec2 creation
# to setup the mongodb instance with authentication.

resource "aws_instance" "db-instance" {
  ami           = data.aws_ami.mongodb-ubuntu.id
  instance_type = "t2.micro"
  key_name      = "backend-dhoondlai-key-pair"

  subnet_id                   = aws_subnet.main-public-subnet-1.id
  vpc_security_group_ids      = [aws_security_group.db-ec2.id]
  associate_public_ip_address = true

  user_data = <<-EOF
  #!/bin/bash -ex
  cp /etc/mongod.conf /etc/mongod.conf.backup
  sed -i "s/^  bindIp:.*$/  bindIp: 0.0.0.0/" /etc/mongod.conf
  sudo systemctl restart mongod
  EOF

  iam_instance_profile = aws_iam_instance_profile.ec2-iam-instance-profile.name

  tags = {
    Name = "dhoondlai-db-instance"
  }
}

resource "aws_iam_instance_profile" "ec2-iam-instance-profile" {
  name = "ec2-iam-instance-profile"
  role = aws_iam_role.ec2-iam-role.name
}

resource "aws_iam_role" "ec2-iam-role" {
  name = "ec2-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
