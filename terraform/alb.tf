
resource "aws_lb" "app_alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]

  enable_deletion_protection = false
  idle_timeout               = 60

  tags = {
    Name    = "app-alb"
    Project = "devops-terraform-project"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name        = "app-tg"
  port        = 8080                    
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"              

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags = {
    Name    = "app-tg"
    Project = "devops-terraform-project"
  }
}


resource "aws_lb_listener" "app_http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# 