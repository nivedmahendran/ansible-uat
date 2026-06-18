variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "server_name" {
  description = "Name of the UAT server"
  type        = string
  default     = "uat-server"
}

variable "server_type" {
  description = "Hetzner server type (CX22 = 2 vCPU, 4 GB RAM)"
  type        = string
  default     = "cx22"
}

variable "server_image" {
  description = "OS image for the server"
  type        = string
  default     = "ubuntu-24.04"
}

variable "location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "hel1"
}

variable "public_ssh_key_path" {
  description = "Path to the public SSH key for server access"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_ssh_key_path" {
  description = "Path to the private SSH key for Ansible"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "cloud_init_path" {
  description = "Path to cloud-init configuration (optional)"
  type        = string
  default     = ""
}

variable "allowed_ips" {
  description = "IPs allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

variable "monitoring_ips" {
  description = "IPs allowed for monitoring tools (Grafana, Prometheus, ArgoCD)"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}
