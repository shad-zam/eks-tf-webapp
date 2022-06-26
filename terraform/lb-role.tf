data "aws_caller_identity" "current" {}

data "template_file" "lb-role" {
  template = file("templates/loadbalancer.tpl")

  vars = {
    acct-number     = data.aws_caller_identity.current.account_id
    region = var.region
    oidc_token = module.eks.oidc_token
  }
  depends_on = [module.eks]
}

# resource "local_file" "lb-role" {
#   content  = data.template_file.lb-role.rendered
#   filename = "poliload-balancer-role-trust-policy.json"
# }

resource "aws_iam_policy" "alb_policy" {
  name = "AWSLoadBalancerControllerIAMPolicy"
  policy = "${file("policies/iam_policy.json")}"
}

resource "aws_iam_role" "lb-role" {
  name                  = "${var.name}-lb-control-role"
  force_detach_policies = true

  assume_role_policy = data.template_file.lb-role.rendered
}

resource "aws_iam_role_policy_attachment" "lb-role" {
  policy_arn = aws_iam_policy.alb_policy.arn
  role       = aws_iam_role.lb-role.name
}