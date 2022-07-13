resource "aws_eks_cluster" "eks-cluster" {
  name = var.cluster_name

  role_arn = aws_iam_role.eks-iam-role.arn

  vpc_config {
    security_group_ids = ["${aws_security_group.security-group.id}"]
    subnet_ids         = ["${aws_subnet.subnet[0].id}", "${aws_subnet.subnet[1].id}"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.iam-role-policy-attachment-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.iam-role-policy-attachment-AmazonEKSServicePolicy,
  ]
}

resource "aws_eks_identity_provider_config" "oidc" {
  cluster_name = aws_eks_cluster.eks-cluster.name

  oidc {
    client_id                     = "sts.amazonaws.com"
    identity_provider_config_name = "provider"
    issuer_url                    = aws_eks_cluster.eks-cluster.endpoint
  }
}


resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "${var.environment_name}-${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.iam-role-worker.arn
  subnet_ids      = aws_subnet.subnet.*.id
  ami_type        = "AL2_x86_64"
  instance_types  = [var.instance_type]

  scaling_config {
    desired_size = var.cluster-node-autoscaling-desired
    max_size     = var.cluster-node-autoscaling-max_size
    min_size     = var.cluster-node-autoscaling-min_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role.iam-role-worker
  ]
}
