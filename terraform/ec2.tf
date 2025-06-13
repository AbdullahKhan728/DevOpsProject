

resource "aws_instance" "metabase" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.private_subnets[0] # private subnet
  vpc_security_group_ids      = [aws_security_group.metabase_sg.id]
  key_name                    = "devops-key"
  associate_public_ip_address = false  # no public IP

  tags = {
    Name = "metabase"
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -ex

    yum update -y
    amazon-linux-extras enable docker
    yum install -y docker
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ec2-user

    docker run -d -p 3000:3000 --name metabase \
      -e MB_DB_TYPE=postgres \
      -e MB_DB_DBNAME=yourdbname \
      -e MB_DB_PORT=5432 \
      -e MB_DB_USER=yourdbuser \
      -e MB_DB_PASS=yourdbpassword \
      -e MB_DB_HOST=your-db-endpoint.rds.amazonaws.com \
      metabase/metabase
  EOF
  )
}
# Find Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Launch Template for EC2
resource "aws_launch_template" "app_lt" {
  name_prefix            = "app-launch-template-"
  image_id               = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  key_name               = "devops-key"  # Your key pair name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]  # Security group

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -ex

    yum update -y

    # Install Docker if not already present
    amazon-linux-extras enable docker
    yum install -y docker git

    # Install AWS CLI v2 if needed
    if ! command -v aws &> /dev/null; then
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install
    fi

    # Install Node.js (optional, only if you need it on the server)
    curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
    yum install -y nodejs

    systemctl enable docker
    systemctl start docker
    usermod -aG docker ec2-user

    # ECR Login
    aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 434374976872.dkr.ecr.us-west-2.amazonaws.com

    # Stop & remove any old container (no error if not present)
    docker stop reactapp || true
    docker rm reactapp || true

    # Pull the new image from ECR and run it
    docker pull 434374976872.dkr.ecr.us-west-2.amazonaws.com/reactapp:latest
    docker run -d --restart unless-stopped --name reactapp -p 8080:8080 434374976872.dkr.ecr.us-west-2.amazonaws.com/reactapp:latest

  EOF
  )
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                 = "app-asg"
  desired_capacity     = 3
  max_size             = 3
  min_size             = 3

  vpc_zone_identifier  = module.vpc.private_subnets

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  tag {
    key                 = "Name"
    value               = "AppServer"
    propagate_at_launch = true
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = "devops-key"
  associate_public_ip_address = true

  tags = {
    Name = "bastion-host"
  }
}

# 