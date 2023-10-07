resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"


  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public_subnet_cidr" {
  count             = length(var.public_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidr, count.index)
  availability_zone = element(var.azs, count.index)

}

resource "aws_subnet" "private_subnet_cidr" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidr, count.index)
  availability_zone = element(var.azs, count.index)


}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id


}

resource "aws_route_table" "second_rt" {
  vpc_id = "aws_vpc.main.id"


}
