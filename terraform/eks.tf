module "eks" {
  source = "../terraform_modules/aws-eks"


  name            = var.name
  environment     = var.environment
  region          = var.region
  k8s_version     = "1.22"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
  kubeconfig_path = var.kubeconfig_path
}

resource "null_resource" "patch-coredns" {
  provisioner "local-exec" {
    command = <<EOT
    kubectl patch deployment coredns \
    -n kube-system \
    --type json \
    -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
    EOT
    
  }
  depends_on = [module.eks]
}

resource "null_resource" "patch-core-deployment" {
  provisioner "local-exec" {
    command = "kubectl rollout restart -n kube-system deployment coredns"
  }
  depends_on = [null_resource.patch-coredns]
}

output "cluster_id" {
  value = module.eks.cluster_id
}

