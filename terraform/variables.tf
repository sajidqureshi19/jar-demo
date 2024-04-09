variable "aws_region" {
  default = "ap-southeast-1"
}
variable "aws_profile" {
  description = "which aws profile to be used"
  default = "default"
}
variable "cluster_name" {
    description = "Provide the name for the eks cluster"
    default = "jar-demo"
}
variable "eks_version" {
    description = "Provide the version for the eks cluster"
    default = "1.27"
}
variable "instance_types_services" {
    description = "Provide the name for the instance_types for services worlload node group"
    default = "m5a.xlarge"
}


variable "ami_type" {
  description = "Provide the AMI type to be used for nodes "
  default = "AL2_x86_64"
}

variable "addons" {
  default = ["aws-efs-csi-driver", "aws-ebs-csi-driver", "kube-proxy", "coredns"]
}


##################### VPC Section #####################
variable "primary_vpc_cidr" {
  description = "Primary CIDR to be used by the VPC and Subnets"
  type        = string
  default     = "10.254.0.0/16"
}

variable "terraform_state_backend_bucket_name" {
  description = "S3 bucket name for storing terraform state file"
  default = "jar-terraform-state-backend"

}

variable "terraform_state_lock_dynamodb_table" {
  description = "provide dynamo table name which can be used as lock on state file"
  default = "jar-terraform-state-lock-table"
}
