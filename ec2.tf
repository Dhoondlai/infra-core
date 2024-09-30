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

resource "aws_instance" "db-instance" {
  ami           = data.aws_ami.mongodb-ubuntu.id
  instance_type = "t2.micro"
  key_name      = "backend-dhoondlai-key-pair"

  subnet_id                   = aws_subnet.main-private-subnet-1.id
  vpc_security_group_ids      = [aws_security_group.main-vpc-web-sg.id]
  associate_public_ip_address = false

  user_data = <<-EOF
  #!/bin/bash -ex
  PUBLIC_DNS=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)
  echo "Public DNS is: $PUBLIC_DNS"
  cp /etc/mongod.conf /etc/mongod.conf.backup
  sed -i "s/^  bindIp:.*$/  bindIp: $PUBLIC_DNS/" /etc/mongod.conf
  sudo systemctl restart mongod

  EOF

  iam_instance_profile = aws_iam_instance_profile.ec2-iam-instance-profile.name

  tags = {
    Name = "backend-parhlai-instance"
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

resource "aws_iam_role_policy_attachment" "ec2-iam-ssm" {
  role       = aws_iam_role.ec2-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
