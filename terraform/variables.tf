##### VPC Vars ##########

variable "create_vpc" {
  description = "Determines whether vpc will be created. if false then you have to pass already available vpc details"
  type        = bool
  default     = true
}

variable "region" {
  description = "Region to create the resources"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "The name to be used on all resources"
  type        = string
  default     = "surepay-eks"
}

variable "environment" {
  description = "The Enviroment type to be used on all resources"
  type        = string
  default     = "Test"
}

variable "cidr" {
  description = "cidr range for the new VPC to create"
  type        = string
  default     = ""
}

variable "private_subnets_cidrs" {
  description = "cidr ranges for the new private subnets"
  type        = list(string)
  default     = []
}

variable "public_subnets_cidrs" {
  description = "cidr ranges for the new public subnets"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "If using the already available VPC. please provide the VPC to be used"
  type        = string
  default     = ""
}

variable "private_subnets_ids" {
  description = "If using the already available VPC. please provide the list of private subnets to be used"
  type        = list(string)
  default     = []
}

variable "public_subnets_ids" {
  description = "If using the already available VPC. please provide the list of public subnets to be used"
  type        = list(string)
  default     = []
}

variable "kubeconfig_path" {
  description = "Path where the config file for kubectl should be written to"
  default = "~/.kube"
}