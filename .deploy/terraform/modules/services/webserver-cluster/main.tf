// load balancer locals 
locals {
  http_port = 80
  https_port = 443
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
}

// security group for load balancer 
resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb"
  vpc_id = aws_vpc.vpc.id
} 

// https inbdound for port 80
resource "aws_security_group_rule" "allow_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port = local.http_port 
  to_port = local.http_port 
  protocol = local.tcp_protocol
  cidr_blocks = local.all_ips
}

// https inbound for port 443
resource "aws_security_group_rule" "allow_https_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port = local.https_port 
  to_port = local.https_port 
  protocol = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type = "egress"
  security_group_id = aws_security_group.alb.id

  from_port = local.any_port
  to_port = local.any_port
  protocol = local.any_protocol
  cidr_blocks = local.all_ips
}

// get the public subnets ids 
data "aws_subnet_ids" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Tier = "Public"
  }

  depends_on = [
    aws_subnet.subnet_1_public,
    aws_subnet.subnet_2_public,
    aws_subnet.subnet_3_public
  ]
}

// load balancer resource 
resource "aws_lb" "nomad_lb" {
  name = var.cluster_name
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.public.ids
  security_groups = [aws_security_group.alb.id]

  access_logs {
    bucket = "fss-service-files"
    prefix = "nomad-lb"
    enabled = true
  }
}

// remote state fetch for db data 
data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = var.db_remote_state_bucket
    key = var.db_remote_state_key
    region = "us-east-2"
  }
}

// user data to be used for launch config 
data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")

  vars = {
    server_port = var.server_port
    DB_ADDRESS = data.terraform_remote_state.db.outputs.address 
    DB_PORT = data.terraform_remote_state.db.outputs.port
    DB_NAME = data.terraform_remote_state.db.outputs.db_name
    
    SECRET_KEY=var.stripe_secret_key
    WEB_APP_URL=var.web_app_url 
    WEB_HOOK_SECRET=var.web_hook_secret 
    GOOGLE_APPLICATION_CREDENTIALS=var.service_account

  }
}

// security group for instances in asg 
resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = var.server_port
    to_port = var.server_port 
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = local.any_port
    to_port = local.any_port
    protocol = local.any_protocol
    cidr_blocks = local.all_ips
  }  
}

// get the latest ami from aws
data "aws_ami" "nomad_ami" {
  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["nomad-ec2-*"]
  }
}

data "aws_iam_role" "logs_role" {
  name = "ec2-cloudwatch"
}
# "nomad_logs_profile"
resource "aws_iam_instance_profile" "nomad_log_profile" {
  name =  var.log_profile_name
  role = data.aws_iam_role.logs_role.name
}

// launch config resource for asg 
resource "aws_launch_configuration" "nomad_lc" {
  name_prefix = "nomad"
  image_id = data.aws_ami.nomad_ami.image_id
  instance_type = var.instance_type
  security_groups = [aws_security_group.instance.id]
  user_data = data.template_file.user_data.rendered       
  associate_public_ip_address = true
  iam_instance_profile = "${aws_iam_instance_profile.nomad_log_profile.name}" 

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [data.aws_ami.nomad_ami]
}

// target group resource
resource "aws_lb_target_group"  "asg" {
  name = var.cluster_name
  port = var.server_port
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15 
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

// asg resource 
resource "aws_autoscaling_group" "nomad_asg" {
  name = "${aws_launch_configuration.nomad_lc.name}-asg"
  launch_configuration = aws_launch_configuration.nomad_lc.name
  vpc_zone_identifier = data.aws_subnet_ids.public.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = var.min_size
  max_size = var.max_size

  tag {
    key = "name"
    value = var.cluster_name
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.nomad_lb.arn
  certificate_arn   = aws_acm_certificate_validation.cert.certificate_arn
  port              = "443"
  protocol          = "HTTPS"

  # by default return a simple 404 page, when route not found
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: Page not found"
      status_code = 404
    }
  }
}

// load balancer listener and redirect all http to https
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.nomad_lb.arn
  port = local.http_port 
  protocol = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.https.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

resource "aws_lb_listener_rule" "asg-http" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}



