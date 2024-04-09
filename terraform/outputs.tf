output "eks_cluster_name" {
  value       = aws_eks_cluster.eks_cluster.name
  description = "Name of the EKS cluster"
}

output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.eks_cluster.endpoint
  description = "Endpoint for the EKS cluster"
}

output "eks_cluster_version" {
  value       = aws_eks_cluster.eks_cluster.version
  description = "Version of the EKS cluster"
}


output "eks_cluster_addons" {
  value       = values(aws_eks_addon.addons).*.addon_name
  description = "Name of the EKS cluster addon"
}
output "bastion_ip" {
  value = aws_instance.bastion_instance.public_ip
}