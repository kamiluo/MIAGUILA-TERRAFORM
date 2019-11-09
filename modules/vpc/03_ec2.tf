###########################################################################################
#--EC2 Instances
###########################################################################################
#-----------------------------------------------------------------------------------------
#--Key Pair for connect EC2 instances
#-----------------------------------------------------------------------------------------

resource "aws_key_pair" "key_pair_ma" {
  key_name   = "${var.key_pair_name}"
  public_key = "${var.key_pair_public_key}"
}

#-----------------------------------------------------------------------------------------
#--AMI Extract the latest ecs ami (This ami can be used next with ECS (Services and Tasks)
#-----------------------------------------------------------------------------------------
data "aws_ami" "latest_ecs_ami" {
most_recent = true
owners = ["591542846629"] # AWS Account

  filter {
      name   = "name"
      values = ["amzn2-ami-ecs-hvm-2.0.*-x86_64-ebs"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }  
}

#------------------------------------------------------------------------------------
#--Launch Template For EC2 Microservices instances
#------------------------------------------------------------------------------------
resource "aws_launch_template" "lt_ma_ec2_microservices" {

    key_name = "${var.key_pair_name}"
    name = "${var.lt_ec2_microservice_name}"
    image_id = "${data.aws_ami.latest_ecs_ami.id}" 
    vpc_security_group_ids =    [
                                "${aws_security_group.sg_ma_ec2_microservices.id}"
                                ]
    block_device_mappings {
        device_name = "/dev/xvda"

        ebs {
            volume_size = 30
            delete_on_termination = true
            encrypted = false
            iops = 0
            volume_type = "gp2"
        }

    }

    instance_type = "${var.lt_ec2_microservice_instance_type}"


    tag_specifications {
      resource_type = "instance"
      tags = merge(
        {
          Name = "${var.lt_ec2_microservice_name}"
        },
        var.tags
      )
    }

    user_data = "${var.lt_ec2_microservice_user_data}"
}

#------------------------------------------------------------------------------------
#--Launch Template For EC2 WebPage instances
#------------------------------------------------------------------------------------
resource "aws_launch_template" "lt_ma_ec2_webpage" {

    key_name = "${var.key_pair_name}"
    name = "${var.lt_ec2_webpage_name}"
    image_id = "${data.aws_ami.latest_ecs_ami.id}" 
    vpc_security_group_ids =    [
                                "${aws_security_group.sg_ma_ec2_webpage.id}"
                                ]
    block_device_mappings {
        device_name = "/dev/xvda"

        ebs {
            volume_size = 30
            delete_on_termination = true
            encrypted = false
            iops = 0
            volume_type = "gp2"
        }

    }

    instance_type = "t2.micro"


    tag_specifications {
      resource_type = "instance"
      tags = merge(
        {
          Name = "lt_ma_ec2_webpage"
        },
        var.tags
      )
    }

    user_data = "${var.lt_ec2_webpage_user_data}"
}

#------------------------------------------------------------------------------------
#--Launch Template For EC2 Bastion instances
#------------------------------------------------------------------------------------
resource "aws_launch_template" "lt_ma_ec2_bastion" {

    key_name = "${var.key_pair_name}"
    name = "${var.lt_ec2_bastion_name}"
    image_id = "${data.aws_ami.latest_ecs_ami.id}" 
    vpc_security_group_ids =    [
                                "${aws_security_group.sg_ma_ec2_bastion.id}"
                                ]
    block_device_mappings {
        device_name = "/dev/xvda"

        ebs {
            volume_size = 30
            delete_on_termination = true
            encrypted = false
            iops = 0
            volume_type = "gp2"
        }

    }

    instance_type = "t2.micro"


    tag_specifications {
      resource_type = "instance"
      tags = merge(
        {
          Name = "lt_ma_ec2_bastion"
        },
        var.tags
      )
    }

    user_data = ""
}

#------------------------------------------------------------------------------------
#--Auto Scaling Group Microservices
#------------------------------------------------------------------------------------
resource "aws_autoscaling_group" "ag_ma_ec2_microservices" {
  name                    = format("ag_ma_ec2_%s_microservices","${var.tags.Environment}")
  max_size                = "${var.ag_ec2_microservices_max}"
  min_size                = "${var.ag_ec2_microservices_min}"
  desired_capacity        = "${var.ag_ec2_microservices_desired}"
  health_check_grace_period = "${var.ag_ec2_microservices_grace}"
  #service_linked_role_arn = "arn:aws:iam::${local.account}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
  vpc_zone_identifier = "${aws_subnet.subnet_ma_private.*.id}"
  launch_template {
    id      = "${aws_launch_template.lt_ma_ec2_microservices.id}"
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    propagate_at_launch = false
    value               = format("ag_ma_ec2_%s_microservices","${var.tags.Environment}")
  }

  tag {
    key                 = "Terraform"
    propagate_at_launch = false
    value               = "${var.tags.Terraform}"
  }

  tag {
    key                 = "Environment"
    propagate_at_launch = false
    value               = "${var.tags.Environment}"
  }

  target_group_arns = "${aws_lb_target_group.tg_ma_ec2_microservices_nlb.*.arn}"

  depends_on = [
                "aws_launch_template.lt_ma_ec2_microservices", 
                "aws_lb_target_group.tg_ma_ec2_microservices_nlb",
                "aws_alb.nlb_ma_ec2_microservices",
                "aws_nat_gateway.nat_ma"
               ]
}

#------------------------------------------------------------------------------------
#--Auto Scaling Group WebPage
#------------------------------------------------------------------------------------
resource "aws_autoscaling_group" "ag_ma_ec2_webpage" {
  name                    = format("ag_ma_ec2_%s_webpage","${var.tags.Environment}")
  max_size                = "1"
  min_size                = "0"
  desired_capacity        = "1"
  health_check_grace_period = "20"
  vpc_zone_identifier = "${aws_subnet.subnet_ma_private.*.id}"
  launch_template {
    id      = "${aws_launch_template.lt_ma_ec2_webpage.id}"
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    propagate_at_launch = false
    value               = format("ag_ma_ec2_%s_webpage","${var.tags.Environment}")
  }

  tag {
    key                 = "Terraform"
    propagate_at_launch = false
    value               = "${var.tags.Terraform}"
  }

  tag {
    key                 = "Environment"
    propagate_at_launch = false
    value               = "${var.tags.Environment}"
  }

  target_group_arns = "${aws_lb_target_group.tg_ma_ec2_webpage_alb.*.arn}"

  depends_on = [
                "aws_launch_template.lt_ma_ec2_webpage", 
                "aws_lb_target_group.tg_ma_ec2_webpage_alb",
                "aws_alb.alb_ma_ec2_webpage",
                "aws_nat_gateway.nat_ma"
               ]
}

#------------------------------------------------------------------------------------
#--Auto Scaling Group Bastion
#------------------------------------------------------------------------------------
resource "aws_autoscaling_group" "ag_ma_ec2_bastion" {
  name                    = format("ag_ma_ec2_%s_bastion","${var.tags.Environment}")
  max_size                = "1"
  min_size                = "0"
  desired_capacity        = "1"
  health_check_grace_period = "20"
  #service_linked_role_arn = "arn:aws:iam::${local.account}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
  vpc_zone_identifier = "${aws_subnet.subnet_ma_public.*.id}"
  launch_template {
    id      = "${aws_launch_template.lt_ma_ec2_bastion.id}"
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    propagate_at_launch = false
    value               = format("ag_ma_ec2_%s_bastion","${var.tags.Environment}")
  }

  tag {
    key                 = "Terraform"
    propagate_at_launch = false
    value               = "${var.tags.Terraform}"
  }

  tag {
    key                 = "Environment"
    propagate_at_launch = false
    value               = "${var.tags.Environment}"
  }

  depends_on = [
                "aws_launch_template.lt_ma_ec2_bastion",
                "aws_nat_gateway.nat_ma"
               ]
}

#------------------------------------------------------------------------------------
#--ELB (Network Load Balancer)
#------------------------------------------------------------------------------------
resource "aws_alb" "nlb_ma_ec2_microservices" {
  access_logs {
    bucket = ""
  }

  enable_http2       = true
  idle_timeout       = 60
  internal           = true
  ip_address_type    = "ipv4"
  load_balancer_type = "network"
  name               = format("nlb-ma-ec2-%s-microservices","${var.tags.Environment}")

  subnets = "${aws_subnet.subnet_ma_public.*.id}"
}

#------------------------------------------------------------------------------------
#--ELB (Application Load Balancer for WebPage)
#------------------------------------------------------------------------------------
resource "aws_alb" "alb_ma_ec2_webpage" {
  access_logs {
    bucket = ""
  }

  enable_http2       = true
  idle_timeout       = 60
  internal           = true
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  name               = format("alb-ma-ec2-%s-webpage","${var.tags.Environment}")
  security_groups    = ["${aws_security_group.sg_ma_alb.id}"]

  subnets = "${aws_subnet.subnet_ma_private.*.id}"

}

#------------------------------------------------------------------------------------
#--Target Group 
#------------------------------------------------------------------------------------
resource "aws_lb_target_group" "tg_ma_ec2_microservices_nlb" {
  count = length(var.tg_ec2_ports)

  name        = format("tg-ma-ec2-%s-micro-nlb-%s","${var.tags.Environment}",element(var.tg_ec2_names, count.index))
  port        = element(var.tg_ec2_ports, count.index)
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = "${aws_vpc.vpc_ma.id}"

  health_check {
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
}

resource "aws_lb_target_group" "tg_ma_ec2_webpage_alb" {
  count = length(var.tg_ec2_web_ports)

  name        = format("tg-ma-ec2-%s-web-alb-%s","${var.tags.Environment}",element(var.tg_ec2_names, count.index))
  port        = element(var.tg_ec2_web_ports, count.index)
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = "${aws_vpc.vpc_ma.id}"

  health_check {
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
}

#-------------------------------------------------------------------------------------
#--Listeners
#-------------------------------------------------------------------------------------
resource "aws_lb_listener" "listener_ma_ec2_microservices_nlb" {
  count = length(aws_lb_target_group.tg_ma_ec2_microservices_nlb.*)
  load_balancer_arn = "${aws_alb.nlb_ma_ec2_microservices.arn}"
  port              = element(aws_lb_target_group.tg_ma_ec2_microservices_nlb.*.port, count.index)
  protocol          = "TCP"
  certificate_arn   = ""

  default_action {
    type             = "forward"
    target_group_arn = element(aws_lb_target_group.tg_ma_ec2_microservices_nlb.*.arn, count.index)
  }
}

resource "aws_lb_listener" "listener_ma_ec2_webpage_alb" {
  count = length(aws_lb_target_group.tg_ma_ec2_webpage_alb.*)
  load_balancer_arn = "${aws_alb.alb_ma_ec2_webpage.arn}"
  port              = element(aws_lb_target_group.tg_ma_ec2_webpage_alb.*.port, count.index)
  protocol          = "HTTP"
  certificate_arn   = ""

  default_action {
    type             = "forward"
    target_group_arn = element(aws_lb_target_group.tg_ma_ec2_webpage_alb.*.arn, count.index)
  }
}