resource "aws_kms_key" "eks_ebs_key" {
  description             = "KMS key for encrypting EBS volumes in EKS Node Group"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "eks_ebs_key_alias" {
  name          = "alias/eks-ebs-key"
  target_key_id = aws_kms_key.eks_ebs_key.key_id
}

###############################

resource "aws_launch_template" "eks_launch_template" {
  name_prefix   = "${var.EKS_CLUSTER_NAME}-launch-template"
  description   = "Launch template for EKS Node Group with encrypted EBS volumes"

  block_device_mappings {
    device_name = "/dev/xvda" # Default root volume for Amazon Linux 2

    ebs {
      volume_size           = 20  # <------ Disk size defined here
      volume_type           = "gp3"
      encrypted             = true
      kms_key_id            = aws_kms_key.eks_ebs_key.arn
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.EKS_CLUSTER_NAME}-node"
    }
  }
}

###############################################

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
  force_update_version = false
  instance_types = ["t3.small"]

  # Attach launch template
  launch_template {
    id      = aws_launch_template.eks_launch_template.id
    version = "$Latest"
  }

  labels = {
    role = "${var.EKS_CLUSTER_NAME}-Node-group-role",
    name = "${var.EKS_CLUSTER_NAME}-node_group"
  }

  version = "1.27"
}
