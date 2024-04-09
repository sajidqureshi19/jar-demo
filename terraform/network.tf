##### Create VPC #####
resource "aws_vpc" "jar-demo" {
  cidr_block             = var.primary_vpc_cidr
  instance_tenancy       = "default"
  enable_dns_hostnames   = true
  enable_dns_support     = true
  tags = {
    Name   = "VPC"
  }
}

##### Web Public Subnets #####
resource "aws_subnet" "web-public-subnet-1" {
  vpc_id                  = aws_vpc.jar-demo.id
  cidr_block              = cidrsubnet(var.primary_vpc_cidr, 5, 0)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Name   = "web-public-subnet-1"
  }
}

resource "aws_subnet" "web-public-subnet-2" {
  vpc_id                  = aws_vpc.jar-demo.id
  cidr_block              = cidrsubnet(var.primary_vpc_cidr, 5, 1)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name   = "web-public-subnet-2"
  }
}

##### Kubernetes Private Subnets #####
resource "aws_subnet" "kube-private-subnet-1" {
  vpc_id                  = aws_vpc.jar-demo.id
  cidr_block              = cidrsubnet(var.primary_vpc_cidr, 5, 3)
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Name   = "kube-private-subnet-1"
  }
}

resource "aws_subnet" "kube-private-subnet-2" {
  vpc_id                  = aws_vpc.jar-demo.id
  cidr_block              = cidrsubnet(var.primary_vpc_cidr, 5, 4)
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name   = "kube-private-subnet-2"
  }
}

resource "aws_subnet" "kube-private-subnet-3" {
  vpc_id                  = aws_vpc.jar-demo.id
  cidr_block              = cidrsubnet(var.primary_vpc_cidr, 5, 5)
  availability_zone       = data.aws_availability_zones.available.names[2]
  tags = {
    Name   = "kube-private-subnet-3"
  }
}

resource "aws_subnet" "bastion" {
  vpc_id            = aws_vpc.jar-demo.id
  cidr_block        = cidrsubnet(var.primary_vpc_cidr, 5, 6)
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "bastion-host"
  }
}
##### Internet Gateway for the VPC #####

resource "aws_internet_gateway" "vpc_internet_gateway" {
  vpc_id = aws_vpc.jar-demo.id

  tags = {
    Name = "internet-gateway"
  }
}

##### Nat gateway #####

resource "aws_eip" "nat-gateway-ip-1" {
  domain="vpc"
  tags = {
    Name = "nat-gateway-ip-1"
  }
}


resource "aws_nat_gateway" "natgateway-1" {
  allocation_id = aws_eip.nat-gateway-ip-1.id
  subnet_id     = aws_subnet.web-public-subnet-1.id

  tags = {
    Name = "natgateway-1"
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.vpc_internet_gateway]
}



##### Web Subnets Routing #####

resource "aws_route_table" "web-subnets-route-table" {
  vpc_id = aws_vpc.jar-demo.id

  tags = {
    Name = "web-subnets-route-table"

  }
}

resource "aws_route" "web-subnets-to-internet-route" {
  route_table_id            = aws_route_table.web-subnets-route-table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.vpc_internet_gateway.id
  depends_on                = [
    aws_route_table.web-subnets-route-table,
    aws_internet_gateway.vpc_internet_gateway
    ]
}

resource "aws_route_table_association" "web-subnet-1-rtb-associatetion" {
  subnet_id      = aws_subnet.web-public-subnet-1.id
  route_table_id = aws_route_table.web-subnets-route-table.id
}

resource "aws_route_table_association" "web-subnet-2-rtb-associatetion" {
  subnet_id      = aws_subnet.web-public-subnet-2.id
  route_table_id = aws_route_table.web-subnets-route-table.id
}


##### Kubernetes Subnets Routing #####

resource "aws_route_table" "kube-subnets-route-table" {
  vpc_id = aws_vpc.jar-demo.id

  tags = {
    Name = "kube-subnets-route-table"

  }
}

resource "aws_route" "kube-subnets-to-internet-route" {
  route_table_id            = aws_route_table.kube-subnets-route-table.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.natgateway-1.id
  depends_on                = [
    aws_route_table.kube-subnets-route-table,
    aws_nat_gateway.natgateway-1
    ]
}

resource "aws_route_table_association" "kube-subnet-1-rtb-associatetion" {
  subnet_id      = aws_subnet.kube-private-subnet-1.id
  route_table_id = aws_route_table.kube-subnets-route-table.id
}

resource "aws_route_table_association" "kube-subnet-2-rtb-associatetion" {
  subnet_id      = aws_subnet.kube-private-subnet-2.id
  route_table_id = aws_route_table.kube-subnets-route-table.id
}

resource "aws_route_table_association" "kube-subnet-3-rtb-associatetion" {
  subnet_id      = aws_subnet.kube-private-subnet-3.id
  route_table_id = aws_route_table.kube-subnets-route-table.id
}
