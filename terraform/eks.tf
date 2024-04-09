
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version = var.eks_version
  vpc_config {
    subnet_ids = [aws_subnet.kube-private-subnet-1.id,aws_subnet.kube-private-subnet-2.id,aws_subnet.kube-private-subnet-3.id]
    security_group_ids = [aws_security_group.cluster-sg.id]
    endpoint_private_access = true
    endpoint_public_access  = false

  }

  depends_on = [
                aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
                aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,]
}

resource "aws_eks_node_group" "services_workloads_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "services_workloads_nodes"
  node_role_arn   = aws_iam_role.node_group_role.arn
  ami_type = var.ami_type

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }
  update_config {
    max_unavailable = 1
  }

  subnet_ids = [aws_subnet.kube-private-subnet-1.id,aws_subnet.kube-private-subnet-2.id,aws_subnet.kube-private-subnet-3.id]

  instance_types = [var.instance_types_services]
  capacity_type  = "SPOT"
  disk_size = 100

  labels = {
    "ng-type" = "services_workloads"
  }

  depends_on = [aws_eks_cluster.eks_cluster,
                aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
                aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
                aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,]
}


resource "aws_eks_addon" "addons" {
  for_each = toset(var.addons)

  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = each.value
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_instance" "bastion_instance" {
  ami                    = "ami-06c4be2792f419b7b"
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.web-public-subnet-2.id
  key_name               = "jar-bastion"
  vpc_security_group_ids     = [aws_security_group.bastion_sg.id, "sg-08d7b13a7d6834b7b"]
  associate_public_ip_address = true

}

resource "aws_autoscaling_schedule" "jar-demo" {
  scheduled_action_name  = "jar-demo"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  time_zone              = "Asia/Kolkata"
  recurrence             = "0 22 * * *"
  start_time             = "2024-04-08T17:45:00Z"
  end_time               = "2024-04-30T05:00:00Z"
  autoscaling_group_name = "eks-services_workloads_nodes-92c75ee3-a8d3-85df-1856-a5f1022d8033"
}

resource "aws_autoscaling_schedule" "jar-demo-scale-up" {
  scheduled_action_name  = "jar-demo-scale-up"
  min_size               = 1
  max_size               = 3
  desired_capacity       = 1
  time_zone              = "Asia/Kolkata"
  recurrence             = "0 10 * * *"
  start_time             = "2024-04-09T05:45:00Z"
  end_time               = "2024-04-30T05:00:00Z"
  autoscaling_group_name = "eks-services_workloads_nodes-92c75ee3-a8d3-85df-1856-a5f1022d8033"
}