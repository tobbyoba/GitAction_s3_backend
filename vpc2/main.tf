module "IAM_module" {
  source = "git::https://github.com/tobbyoba/IAM_eks.git//IAM_module"
  region = "us-east-1"
}


#create vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = {
    Name = "main"
  }
}

# create public-subnet
resource "aws_subnet" "public_subnet_cidr" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name                         = "public"
    "kubernetes.io/role-elb"     = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }
}

#create private-subnet
resource "aws_subnet" "private_subnet_cidr" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidr, count.index)
  availability_zone = element(var.azs, count.index)


  tags = {
    Name                              = "private"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }


}

#create IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }

}

#Create EIP
resource "aws_eip" "elastic" {
  tags = {
    Name = "nat"
  }
}

#create nat gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.elastic.id
  subnet_id     = aws_subnet.public_subnet_cidr[0].id

  depends_on = [aws_internet_gateway.igw]

}

#create private route-table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  depends_on = [aws_subnet.private_subnet_cidr]

  tags = {
    Name = "private"
  }
}

#create public route-table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  depends_on = [aws_subnet.public_subnet_cidr]

  tags = {
    Name = "public"
  }

}

#create public-route
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

  depends_on = [aws_route_table.public]

}

#create private-route
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.nat.id
  destination_cidr_block = "0.0.0.0/0"

  depends_on = [aws_route_table.private]

}

#create private route-table association
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr)

  subnet_id      = element(aws_subnet.private_subnet_cidr[*].id, count.index)
  route_table_id = aws_route_table.private.id

  depends_on = [aws_route.private_nat_gateway, aws_subnet.private_subnet_cidr]

}

#create public route-table association
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public_subnet_cidr)
  subnet_id      = element(aws_subnet.public_subnet_cidr[*].id, count.index)
  route_table_id = aws_route_table.public.id

  depends_on = [aws_route.public_internet_gateway, aws_subnet.public_subnet_cidr]

}

####