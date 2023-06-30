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

  env = "second"
  vpc_id      = "vpc-091ee29049a724218"
  eks_name    = "altair"
  eks_version = "1.23"
  subnets     = ["subnet-048b9f16daad6dd97", "subnet-0dd1ae5f0542f9f9c"]
#   vpn_cidr    = data.terraform_remote_state.networking.outputs.public_subnets_cidr

  node_groups = {
  #   first = {
  #     node_group_name = "dex"
  #     desired_size    = 3
  #     max_size        = 4
  #     min_size        = 1

  #     ami_type       = "AL2_x86_64"
  #     instance_types = ["t3.medium"]
  #     taints = [
  #       {
  #         key    = "role"
  #         value  = "dex"
  #         effect = "NO_SCHEDULE"
  #       }]
  #     labels = {
  #       role = "dex"
  # }
  #   },
  #   first = {
  #     node_group_name = "argocd"
  #     desired_size    = 1
  #     max_size        = 2
  #     min_size        = 1

  #     ami_type       = "AL2_x86_64"
  #     instance_types = ["t3.medium"]
  #     taints = [
  #       {
  #         key    = "role"
  #         value  = "argocd"
  #         effect = "NO_SCHEDULE"
  #       }]
  #     labels = {
  #       role = "argocd"
  # }
  #   },
    first = {
      node_group_name = "test2"
      desired_size    = 3
      max_size        = 4
      min_size        = 2

      ami_type       = "AL2_x86_64"
      instance_types = ["t3.medium"]
    },
  }
}
