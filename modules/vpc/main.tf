#--------------------------------------------------------------
#--VPC
#--------------------------------------------------------------
resource "aws_vpc" "vpc_ma" {
  cidr_block       = "${var.cidr}"
  instance_tenancy = "${var.tenancy}"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      "Name" = format("vpc_ma_%s","${var.tags.Environment}")
    },
    var.tags
  )
}

#--------------------------------------------------------------
#--INTERNET GATEWAY
#--------------------------------------------------------------
resource "aws_internet_gateway" "igw_ma" {
  vpc_id = "${aws_vpc.vpc_ma.id}"

  tags = merge(
    {
    Name = format("igw_ma_%s","${var.tags.Environment}")
    },
    var.tags
  )
  depends_on = ["aws_vpc.vpc_ma"]
}

#--------------------------------------------------------------
#--PUBLIC SUBNETS
#--------------------------------------------------------------
resource "aws_subnet" "subnet_ma_public" {
  count = length(var.public_subnets)

  vpc_id                  = "${aws_vpc.vpc_ma.id}"
  cidr_block              = element(concat(var.public_subnets, [""]), count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    {
    Name = format("subnet_ma_public_%s_%s","${var.tags.Environment}",element(var.azs,count.index))
    },
    var.tags
  )
  depends_on = ["aws_vpc.vpc_ma"]
}

#--------------------------------------------------------------
#--PRIVATE SUBNETS
#--------------------------------------------------------------
resource "aws_subnet" "subnet_ma_private" {
  count = length(var.private_subnets)

  vpc_id                  = "${aws_vpc.vpc_ma.id}"
  cidr_block              = element(concat(var.private_subnets, [""]), count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    {
    Name = format("subnet_ma_private_%s_%s","${var.tags.Environment}",element(var.azs,count.index))
    },
    var.tags
  )
  depends_on = ["aws_vpc.vpc_ma"]
}

#-----------------------------------------------------------------------------------
#--NAT Defautl for Internet Acces (Public Subnets) and New One for Private Subnets
#-----------------------------------------------------------------------------------
resource "aws_eip" "eip_ma" {
  vpc = true

  tags = merge(
    {
      "Name" = format("eip_ma_%s","${var.tags.Environment}")
    },
    var.tags
  )
}

resource "aws_nat_gateway" "nat_ma" {
  allocation_id = "${aws_eip.eip_ma.id}"
  subnet_id     = "${aws_subnet.subnet_ma_public[0].id}"

  tags = merge(
    {
    Name = format("nat_ma_%s","${var.tags.Environment}")
    },
    var.tags
  )

  depends_on = ["aws_internet_gateway.igw_ma","aws_eip.eip_ma"]
}

resource "aws_default_route_table" "route_table_ma_default" {
  default_route_table_id = "${aws_vpc.vpc_ma.default_route_table_id}"

  route {
    cidr_block     = "${var.default_cidr}"
    gateway_id = "${aws_internet_gateway.igw_ma.id}"
  }

  tags = merge(
    {
      Name = format("route_table_ma_%s_default","${var.tags.Environment}")
    },
    var.tags
  )
}


resource "aws_route_table" "route_table_ma_nat" {
  vpc_id = "${aws_vpc.vpc_ma.id}"

  route {
    cidr_block     = "${var.default_cidr}"
    nat_gateway_id = "${aws_nat_gateway.nat_ma.id}"
  }

  tags = merge(
    {
    Name = format("route_table_ma_%s_nat","${var.tags.Environment}")
    },
    var.tags
  )
}

resource "aws_route_table_association" "route_table_association_ma_private" {
  count = length(var.private_subnets)
  route_table_id = "${aws_route_table.route_table_ma_nat.id}"
  subnet_id      = element(aws_subnet.subnet_ma_private.*.id, count.index)
  depends_on = ["aws_route_table.route_table_ma_nat"]
}

resource "aws_route_table_association" "route_table_association_ma_public" {
  count = length(var.public_subnets)
  route_table_id = "${aws_default_route_table.route_table_ma_default.id}"
  subnet_id      = element(aws_subnet.subnet_ma_public.*.id, count.index)
  depends_on = ["aws_default_route_table.route_table_ma_default"]
}
#-----------------------------------------------------------------------------------
#--Security Group for EC2 Instances
#-----------------------------------------------------------------------------------
resource "aws_security_group" "sg_ma_ec2_microservices" {
  name        = format("seg_ma_ec2_%s_microservices","${var.tags.Environment}")
  description = "${var.sg_ma_ec2_microservices_desc}"
  vpc_id      = "${aws_vpc.vpc_ma.id}"

  ingress {
    from_port   = 3001
    to_port     = 3003
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr}"]
    description = "Microservicios"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr}"]
    description = "SSH"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.default_cidr}"]
  }


  tags = merge(
    {
      Name = format("sg_ma_ec2_%s_microservices","${var.tags.Environment}")
    },
    var.tags
  )

}

resource "aws_security_group" "sg_ma_ec2_webpage" {
  name        = format("seg_ma_ec2_%s_webpage","${var.tags.Environment}")
  description = "WebPage Sec Group"
  vpc_id      = "${aws_vpc.vpc_ma.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr}"]
    description = "HTTP"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr}"]
    description = "SSH"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.default_cidr}"]
  }


  tags = merge(
    {
      Name = format("sg_ma_ec2_%s_webpage","${var.tags.Environment}")
    },
    var.tags
  )

}

resource "aws_security_group" "sg_ma_ec2_bastion" {
  name        = format("seg_ma_ec2_%s_bastion","${var.tags.Environment}")
  description = "Bastion Sec Group"
  vpc_id      = "${aws_vpc.vpc_ma.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.default_cidr}"]
    description = "SSH"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.default_cidr}"]
  }


  tags = merge(
    {
      Name = format("sg_ma_ec2_%s_bastion","${var.tags.Environment}")
    },
    var.tags
  )

}

resource "aws_security_group" "sg_ma_alb" {
  name        = format("sg_ma_alb_%s","${var.tags.Environment}")
  description = "ALB Sec Group"
  vpc_id      = "${aws_vpc.vpc_ma.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr}"]
    description = "HTTP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.default_cidr}"]
  }


  tags = merge(
    {
      Name = format("sg_ma_alb_%s","${var.tags.Environment}")
    },
    var.tags
  )

}

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

#-------------------------------------------------------------------------------------
#--Privated Hosted Zone
#-------------------------------------------------------------------------------------

resource "aws_route53_zone" "route53_ma_private" {
  name = "devops-test-miaguila.com"

  vpc {
    vpc_id = "${aws_vpc.vpc_ma.id}"
  }
}

resource "aws_route53_record" "reoute_53_nlb_dns" {
  zone_id = "${aws_route53_zone.route53_ma_private.zone_id}"
  name    = "api.devops-test-miaguila.com"
  type    = "A"

  alias {
    name                   = "${aws_alb.nlb_ma_ec2_microservices.dns_name}"
    zone_id                = "${aws_alb.nlb_ma_ec2_microservices.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "route53_record_alb_dns" {
  zone_id = "${aws_route53_zone.route53_ma_private.zone_id}"
  name    = "devops-test-miaguila.com"
  type    = "A"

  alias {
    name                   = "${aws_alb.alb_ma_ec2_webpage.dns_name}"
    zone_id                = "${aws_alb.alb_ma_ec2_webpage.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "route53_record_s3_dns" {
  zone_id = "${aws_route53_zone.route53_ma_private.zone_id}"
  name    = "admin.devops-test-miaguila.com"
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.s3_ma_admin.website_domain}"
    zone_id                = "${aws_s3_bucket.s3_ma_admin.hosted_zone_id}"
    evaluate_target_health = true
  }
}