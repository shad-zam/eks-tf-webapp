resource "helm_release" "lbc" {

    depends_on = [
      null_resource.patch-coredns
    ]
  name            = "aws-load-balancer-controller"
  chart           = "aws-load-balancer-controller"
  repository      = "https://aws.github.io/eks-charts"
  namespace       = "kube-system"
  cleanup_on_fail = true

  set {
    name = "clusterName"
    value = "surepay-eks-Test"
  }
   set {
    name = "region"
    value = var.region
  }
   set {
    name = "vpcId"
    value = module.vpc.vpc_id
   }
      set {
    name = "serviceAccount.name"
    value = "aws-load-balancer-controller "
   }

    set {
    name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.lb-role.arn
   }

}