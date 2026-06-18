terraform {
  required_version = ">= 1.5"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.49"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "default" {
  name       = "uat-server"
  public_key = file(var.public_ssh_key_path)
}

resource "hcloud_server" "uat" {
  name        = var.server_name
  server_type = var.server_type
  image       = var.server_image
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.id]
  user_data   = file(var.cloud_init_path != "" ? var.cloud_init_path : "${path.module}/cloud-init.yml")

  labels = {
    environment = "uat"
    managed-by  = "terraform"
    project     = "ansible-uat"
  }
}

resource "hcloud_firewall" "uat" {
  name = "${var.server_name}-firewall"

  rule {
    direction = "in"
    protocol  = "tcp"
    source_ips = var.allowed_ips
    port      = "22"
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    source_ips = ["0.0.0.0/0", "::/0"]
    port      = "80"
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    source_ips = ["0.0.0.0/0", "::/0"]
    port      = "443"
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    source_ips = var.monitoring_ips
    port      = "3000"
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    source_ips = var.monitoring_ips
    port      = "9090"
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    source_ips = var.monitoring_ips
    port      = "32050"
  }
}

resource "hcloud_firewall_attachment" "uat" {
  firewall_id = hcloud_firewall.uat.id
  server_ids  = [hcloud_server.uat.id]
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../inventory.ini"
  content  = <<-EOT
    [uat]
    ${hcloud_server.uat.ipv4_address} ansible_user=root ansible_ssh_private_key_file=${var.private_ssh_key_path}

    [all:vars]
    ansible_python_interpreter=/usr/bin/python3
  EOT
}
