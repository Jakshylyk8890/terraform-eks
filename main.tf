#===================== networking/main.tf ======================

# module "networking" {
#   source = "git::https://github.com/tynchtyk642/terraform-aws-modules.git//networking?ref=main" # <== Path to  the networking module.

#   env              = var.env
#   vpc_cidr         = var.vpc_cidr
#   public_sn_count  = 3
#   private_sn_count = 3
# }

#===================== EKS Cluster's root module =========================
module "eks_cluster" {
  source = "git::https://tynchtyk642@github.com/tynchtyk642/terraform-aws-modules.git//eks_cluster?ref=main"

  env = "test"
  vpc_id      = "vpc-06aa32bfa737e9808"
  eks_name    = "altair"
  eks_version = "1.22"
  subnets     = ["subnet-0eee6e641b24de4e0", "subnet-00e0577e2a01a8dc3"]
#   vpn_cidr    = data.terraform_remote_state.networking.outputs.public_subnets_cidr

  node_groups = {
    first = {
      node_group_name = "test2"
      desired_size    = 3
      max_size        = 4
      min_size        = 1

      ami_type       = "AL2_x86_64"
      instance_types = ["t3.medium"]
    },
    # second = {
    #   node_group_name = "test3"
    #   desired_size    = 2
    #   max_size        = 3
    #   min_size        = 1

    #   ami_type       = "AL2_x86_64"
    #   instance_types = ["t2.micro"]
    # },
    # third = {
    #   node_group_name = "test4"
    #   desired_size    = 2
    #   max_size        = 3
    #   min_size        = 1

    #   ami_type       = "AL2_x86_64"
    #   instance_types = ["t2.micro"]
    # },
  }
}
