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