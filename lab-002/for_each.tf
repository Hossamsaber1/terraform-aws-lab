resource "aws_subnet" "subnets" {
  for_each = var.subnets

  vpc_id     = aws_vpc.main.id
  cidr_block = each.value.cidr

  tags = {
    Name = each.key
  }
}