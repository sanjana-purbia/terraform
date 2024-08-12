provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "igw-tf"
  }
}

resource "aws_subnet" "public_tf" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name : "public-tf"
  }
}

resource "aws_subnet" "private_tf" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name : "private_tf"
  }
}

resource "aws_route_table" "table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name : "Public_rtf"
  }
}
resource "aws_route_table_association" "pub" {
  subnet_id      = aws_subnet.public_tf.id
  route_table_id = aws_route_table.table.id
}
resource "aws_eip" "name" {

}
resource "aws_nat_gateway" "nat" {
  connectivity_type = "public"
  allocation_id     = aws_eip.name.id
  subnet_id         = aws_subnet.public_tf.id
  tags = {
    Name : "nat-tf"
  }
}
resource "aws_route_table" "private_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name : "private_rtf"
  }
}
resource "aws_route_table_association" "pvt" {
  subnet_id      = aws_subnet.private_tf.id
  route_table_id = aws_route_table.private_table.id
}