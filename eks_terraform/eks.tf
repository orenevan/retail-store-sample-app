

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.16"

  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  cluster_addons = {
    vpc-cni = {
      before_compute = true
      most_recent    = true
      configuration_values = jsonencode({
        env = {
          ENABLE_POD_ENI                    = "true"
          ENABLE_PREFIX_DELEGATION          = "true"
          POD_SECURITY_GROUP_ENFORCING_MODE = "standard"
        }
        enableNetworkPolicy = "true"
      })
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  create_cluster_security_group = false
  create_node_security_group    = false

  eks_managed_node_groups = {
    default = {
      instance_types       = [var.eks_instance_type]
      force_update_version = true
      release_version      = var.ami_release_version

      min_size     = var.node_groups_min_size
      max_size     = var.node_groups_max_size
      desired_size = var.node_groups_desired_size

      update_config = {
        max_unavailable_percentage = 50
      }

      labels = {
        workshop-default = "yes"
      }
    }
  }

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::171536096671:user/testeks"
      username = "testeks"
      groups   = ["admins"]
    },
    {
      userarn  = "arn:aws:iam::171536096671:user/orenevan"
      username = "orenevan"
      groups   = ["admins"]
    },
  ]

  tags = merge(local.tags, {
    "karpenter.sh/discovery" = var.cluster_name
  })
}


provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}




module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "1.14.0" #ensure to update this to the latest/desired version

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    # vpc-cni = {
    #   most_recent = true
    # }
    kube-proxy = {
      most_recent = true
    }
  }

  enable_aws_load_balancer_controller    = true
  #enable_cluster_proportional_autoscaler = true
  enable_karpenter                       = true
  enable_kube_prometheus_stack           = true
  enable_metrics_server                  = true
  enable_external_dns                    = true
  enable_cert_manager                    = true
  cert_manager_route53_hosted_zone_arns  = ["arn:aws:route53:::hostedzone/XXXXXXXXXXXXX"]

  tags = {
    Environment = "dev"
  }
}



# Creating namespace with the Kubernetes provider is better than auto-creation in the helm_release.
# You can reuse the namespace and customize it with quotas and labels.
# resource "kubernetes_namespace" "monitoring" {
#   metadata {
#     name = "monitoring"
#   }
# }

# resource "helm_release" "prometheus" {
#   chart      = "prometheus"
#   name       = "prometheus"
#   namespace  = "monitoring"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   version    = "15.5.3"

#   set {
#     name  = "podSecurityPolicy.enabled"
#     value = true
#   }

#   set {
#     name  = "server.persistentVolume.enabled"
#     value = false
#   }

#   # You can provide a map of value using yamlencode. Don't forget to escape the last element after point in the name
#   set {
#     name = "server\\.resources"
#     value = yamlencode({
#       limits = {
#         cpu    = "200m"
#         memory = "50Mi"
#       }
#       requests = {
#         cpu    = "100m"
#         memory = "30Mi"
#       }
#     })
#   }
# }

# resource "kubernetes_secret" "grafana" {
#   metadata {
#     name      = "grafana"
#     namespace = "monitoring"
#   }

#   data = {
#     admin-user     = "admin"
#     admin-password = random_password.grafana.result
#   }
# }

# resource "random_password" "grafana" {
#   length = 24
# }

# resource "helm_release" "grafana" {
#   chart      = "grafana"
#   name       = "grafana"
#   repository = "https://grafana.github.io/helm-charts"
#   namespace  = "monitoring"
#   version    = "6.24.1"

#   # values = [
#   #   templatefile("${path.module}/templates/grafana-values.yaml", {
#   #     admin_existing_secret = kubernetes_secret.grafana.metadata[0].name
#   #     admin_user_key        = "admin-user"
#   #     admin_password_key    = "admin-password"
#   #     prometheus_svc        = "${helm_release.prometheus.name}-server"
#   #     replicas              = 1
#   #   })
#   # ]
# }
