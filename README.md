# eks-tf-webapp

This repository has terraform configuration files to create a simple nginx deployment on EKS using terraform. 
The nginx welcome page will be desplayed after successfull deployment.

The challenge here is to create kubenetes app fronted by a ALB. as ALB provides a lot more functionalities compared to clasic loadbalance. we need to create some extra resources to support ALB. following AWS guidelines are followed for this.
[https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html]

As fargate lauch method is utilized we need to patch the core-dns deployment to work with fargate nodes. a local provisioner is used for this. 



## Prerequisites

Terraform version 13 or higher should be installed on the running machine. kubectl is recomended to have but not required as all the kubenetes resources are also provisioned via the terraform configurations.

## Resources

Below listed resources will be created.

* A VPC with the CIDR range with public & private subnets as provided.
* A EKS cluster with fargate profile.
* cloudwatch log group 
* Required IAM roles & IAM policies.
* Helm chart for AWS load balancer controller.
* kubernetes namespace,deployment,service & ingress.

## How to run these scripts

1. clone this repository
2. goto Terraform directory
3. create a tfvar file with required variables (Refer 'vars.tfvar')
4. Run 'terraform init' to innitiate the terraform
5. Run 'terraform plan -out=terraform.provisionplan -var-file=<created_tfvar.file>' eg- $ terraform plan -out=terraform.provisionplan -var-file=inputs.tfvar
5. Run 'terraform apply "terraform.provisionplan" ' This will create the exact same as the plan output which got desplayed.

