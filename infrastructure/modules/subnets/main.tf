# Public Subnets
resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone       = var.subnet_az[count.index]
  tags = {
    Name = "${var.env}-public-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id       = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.env}-public-rtb"
  }
}

resource "aws_route_table_association" "public_subnet_assoc" {
  count          = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_subnet" "private_subnet" {
  count               = 2
  vpc_id              = var.vpc_id
  cidr_block          = cidrsubnet(var.vpc_cidr, 4, count.index + 2)
  availability_zone   = var.subnet_az[count.index]
  tags = {
    Name = "${var.env}-private-subnet-${count.index}"
  }
}


resource "aws_route_table" "private_rtb" {
  vpc_id       = var.vpc_id
  tags   = {
    Name = "${var.env}-private-rtb"
  }
}

resource "aws_route_table_association" "private_subnet_assoc" {
  count          = 2
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rtb.id
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private_subnet[*].id
  private_dns_enabled = true
  security_group_ids = [var.vpc_endpoint_sg]
  tags = {
    Name = "${var.env}-ecr-endpoint-data-plane"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private_subnet[*].id
  private_dns_enabled = true
  security_group_ids = [var.vpc_endpoint_sg]


  tags = {
    Name = "${var.env}-ecr-endpoint-control-plane"
  }
}

resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.private_rtb.id]

  tags = {
    "Name" = "${var.env}-s3-gateway"
  }
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private_subnet[*].id
  private_dns_enabled = true
  security_group_ids = [var.vpc_endpoint_sg]
}
