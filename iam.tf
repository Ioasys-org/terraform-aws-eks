resource "aws_iam_instance_profile" "iam-instance-profile-worker" {
  name = "${var.environment_name}-${var.cluster_name}-iam-instance-profile-worker"
  role = aws_iam_role.iam-role-worker.name
}

data "tls_certificate" "cert" {
  url = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc" {
  url = aws_eks_cluster.eks-cluster.identity.0.oidc.0.issuer

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    data.tls_certificate.cert.certificates[0].sha1_fingerprint
  ]
}

resource "aws_iam_role_policy_attachment" "iam-role-worker-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.iam-role-worker.name
}


resource "aws_iam_role_policy_attachment" "iam-role-worker-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.iam-role-worker.name
}

resource "aws_iam_role_policy_attachment" "iam-role-worker-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.iam-role-worker.name
}

resource "aws_iam_role" "iam-role-worker" {
  name = "${var.environment_name}-${var.cluster_name}-iam-role-worker"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "eks-iam-role" {
  name = "${var.environment_name}-${var.cluster_name}-eks-iam-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "iam-role-policy-attachment-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-iam-role.name
}

resource "aws_iam_role_policy_attachment" "iam-role-policy-attachment-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-iam-role.name
}
