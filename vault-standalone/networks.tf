resource "aws_security_group" "conor-vault-sg" {

  name = "conor-vault-sg"
  description = "Security Group for Conor Test"
  vpc_id = "${aws_vpc.conor-vault-vpc.id}"

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_vpc" "conor-vault-vpc" {
  cidr_block       = "10.0.0.0/16"
#  security_groups = ["${aws_security_group.conor-vault-sg.id}"]
  tags = {
    Name = "Conor Vault VPC"
  }
}

resource "aws_main_route_table_association" "conor-vpc-route-association" {
  vpc_id = aws_vpc.conor-vault-vpc.id
  route_table_id = aws_route_table.conor-route-table.id
}

# Created this because vpc_id is not supported for aws_instance resource type:
resource "aws_subnet" "conor-subnet" {
  vpc_id            = aws_vpc.conor-vault-vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "conor-tf-subnet"
  }
}


# I was unable to connect to the instance, even with a public IP, so adding an IGW:
resource "aws_internet_gateway" "conor-gw" {
  vpc_id = aws_vpc.conor-vault-vpc.id
}

# The route table also needed the IGW attached to it:
# Current issue is it's creating a second route table for the VPC, which the instance is attaching to, and the route table with the CORRECT info is not being attached correctly.
# Consider https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#main_route_table_id  -  for establishing this connection
resource "aws_route_table" "conor-route-table" {
  vpc_id = aws_vpc.conor-vault-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.conor-gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.conor-gw.id
  }

#  route {
#    ipv6_cidr_block        = "::/0"
#    egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
#  }

  tags = {
    Name = "Route table for TF tests"
  }
}

### Check the route table. It needs to have both the local 10.0.0.0/16 route and the 0.0.0.0/0 dst route (target should be the igw being set up)

/*
The aws_route_table resource you posted creates a new route table in your VPC. It is possible that you have another route table in your VPC that was created outside of this configuration or by another configuration.

By default, when you create a VPC, it automatically creates a main route table and assigns it to the VPC. This main route table has a default route (0.0.0.0/0) that sends all Internet-bound traffic to an Internet Gateway (if you have created one in your VPC).

The aws_route_table resource in your configuration creates an additional route table in your VPC, and it has a name of "Route table for TF tests". This route table has both a private route (10.0.0.0/16) and a public route (0.0.0.0/0) that allows all outgoing traffic from the VPC to be routed out to the internet via the Internet Gateway.

Therefore, you should see two route tables in your VPC: one main route table and one additional route table that was created by your configuration.
*/