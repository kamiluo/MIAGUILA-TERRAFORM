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