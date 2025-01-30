# Create a dedicated KMS key for EBS encryption
resource "aws_kms_key" "eks_ebs_key" {
  description             = "KMS key for encrypting EBS volumes in EKS Node Group"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

# Attach an alias to the KMS key (optional but recommended)
resource "aws_kms_alias" "eks_ebs_key_alias" {
  name          = "alias/eks-ebs-key"
  target_key_id = aws_kms_key.eks_ebs_key.key_id
}

# Modify your existing EKS Node Group to use the new KMS Key
resource "aws_eks_node_group" "node_group" {
  cluster_name    = var.EKS_CLUSTER_NAME
  node_group_name = "${var.EKS_CLUSTER_NAME}-node_group"
  node_role_arn   = var.NODE_GROUP_ARN

  subnet_ids = [
    var.PRI_SUB3_ID,
    var.PRI_SUB4_ID
  ]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  ami_type      = "AL2_x86_64"
  capacity_type = "ON_DEMAND"
  disk_size     = 20
  force_update_version = false
  instance_types = ["t3.small"]

  labels = {
    role = "${var.EKS_CLUSTER_NAME}-Node-group-role",
    name = "${var.EKS_CLUSTER_NAME}-node_group"
  }

  version = "1.27"

  # Enable EBS encryption using the KMS key
  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.eks_ebs_key.arn
    }
  }
}
