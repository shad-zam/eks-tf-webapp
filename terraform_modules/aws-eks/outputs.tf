output "kubectl_config" {
  description = "Path to new kubectl config file"
  value       = pathexpand("${var.kubeconfig_path}/config")
}

output "cluster_id" {
  description = "ID of the created cluster"
  value       = try(aws_eks_cluster.main.id, "")

}

output "cluster_arn" {
  description = "arn of the created cluster"
  value       = try(aws_eks_cluster.main.arn, "")

}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = try(aws_eks_cluster.main.endpoint, "")
}

output "cluster_ca_certificate" {
  description = "Endpoint for your Kubernetes API server"
  value       = try(data.aws_eks_cluster.cluster.certificate_authority[0].data, "")
}

output "oidc_token" {
  value = split("/", data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer)[4]

  # value = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

output "cluster_tokent_auth" {
  value = data.aws_eks_cluster_auth.cluster
}



