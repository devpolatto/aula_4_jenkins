terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.23.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

provider "digitalocean" {
  token = var.token
}

data "digitalocean_ssh_key" "ssh-key" {
  name = "Dell_G3"
}

resource "digitalocean_droplet" "jenkins" {
  image  = "ubuntu-18-04-x64"
  name   = "jenkins-vm"
  region = var.region
  size   = "s-1vcpu-1gb"

  ssh_keys = [data.digitalocean_ssh_key.ssh-key.id]

  tags = var.tags
}

resource "digitalocean_kubernetes_cluster" "cluster_k8s" {
  name   = "k8s"
  region = var.region
  version = "1.24.4-do.0"

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}

output "jenkins_ip" {
  value = digitalocean_droplet.jenkins.ipv4_address
}

resource "local_file" "kube_config" {
    content  = digitalocean_kubernetes_cluster.cluster_k8s.kube_config.0.raw_config
    filename = "kube_config.yaml"
}