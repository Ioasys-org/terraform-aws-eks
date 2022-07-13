resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = (tomap({
    "Name" : "${var.environment_name}-${var.cluster_name}-cluster-vpc",
    "kubernetes.io/cluster/${var.cluster_name}" : "shared",
  }))
}

resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.environment_name}-${var.cluster_name}-cluster-internet-gateway"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "subnet" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true


  tags = (tomap({
    "Name" : "${var.environment_name}-${var.cluster_name}-subnet",
    "kubernetes.io/cluster/${var.cluster_name}" : "shared",
  }))
}

resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }
}

resource "aws_route_table_association" "route-table-association" {
  count = 2

  subnet_id      = aws_subnet.subnet.*.id[count.index]
  route_table_id = aws_route_table.route-table.id
}


resource "aws_security_group" "node-security-group" {
  name        = "${var.environment_name}-${var.cluster_name}-node-security-group"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = (tomap({
    "Name" : "${var.environment_name}-${var.cluster_name}-node-security-group",
    "kubernetes.io/cluster/${var.cluster_name}" : "owned",
  }))
}

resource "aws_security_group" "security-group" {
  name        = "${var.environment_name}-${var.cluster_name}-security-group"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.environment_name}-${var.cluster_name}-security-group"
  }
}

resource "aws_security_group_rule" "security-group-rule-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.node-security-group.id
  source_security_group_id = aws_security_group.node-security-group.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "security-group-rule-https" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node-security-group.id
  source_security_group_id = aws_security_group.security-group.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "security-group-rule-others" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node-security-group.id
  source_security_group_id = aws_security_group.security-group.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "security-group-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.security-group.id
  source_security_group_id = aws_security_group.node-security-group.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress-workstation-https" {
  cidr_blocks       = ["201.80.1.224/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.security-group.id
  to_port           = 443
  type              = "ingress"
}
