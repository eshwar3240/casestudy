provider "aws" {
  region = "ap-south-1"
}

resource "null_resource" "kops_create_cluster" {
  provisioner "local-exec" {
    command = <<EOT
      kops create cluster \
      --name=k8s.example.com \
      --state=s3://my-kops-state-bucket \
      --zones=ap-south-1a \
      --networking=calico \
      --master-size=t2.medium \
      --node-size=t2.medium \
      --node-count=2
    EOT
    environment = {
      AWS_ACCESS_KEY_ID     = var.aws_access_key_id
      AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key
    }
  }

  provisioner "local-exec" {
    command = <<EOT
      kops update cluster --name=k8s.example.com --state=s3://my-kops-state-bucket --yes
    EOT
    environment = {
      AWS_ACCESS_KEY_ID     = var.aws_access_key_id
      AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key
    }
  }
}

variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
