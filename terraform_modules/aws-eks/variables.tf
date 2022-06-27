variable "name" {
  description = "the name of your stack, e.g. \"demo\""
  type        = string
}

variable "environment" {
  description = "the name of your environment, e.g. \"dev\""
  type        = string
}

variable "region" {
  description = "the AWS region in which resources are created, you must set the availability_zones variable as well if you define this value to something other than the default"
  type        = string
}

variable "k8s_version" {
  description = "Kubernetes version."
  type        = string
  default     = "1.21"
}

variable "vpc_id" {
  description = "The VPC the cluser should be created in"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "kubeconfig_path" {
  description = "Path where the config file for kubectl should be written to"
  type        = string
  default     = "~/.kube/config"
}

variable "fargate_ns" {
  description = "Namspaces to be added to fargate cluster"
  type        = list(string)
}
