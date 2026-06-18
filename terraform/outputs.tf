output "server_ipv4" {
  description = "Public IPv4 address of the UAT server"
  value       = hcloud_server.uat.ipv4_address
}

output "server_ipv6" {
  description = "Public IPv6 address of the UAT server"
  value       = hcloud_server.uat.ipv6_address
}

output "server_name" {
  description = "Name of the UAT server"
  value       = hcloud_server.uat.name
}

output "app_url" {
  description = "Application URL"
  value       = "http://${hcloud_server.uat.ipv4_address}"
}

output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = "http://${hcloud_server.uat.ipv4_address}:3000"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "http://${hcloud_server.uat.ipv4_address}:9090"
}

output "argocd_url" {
  description = "ArgoCD URL"
  value       = "http://${hcloud_server.uat.ipv4_address}:32050"
}

output "inventory_file" {
  description = "Path to the generated Ansible inventory"
  value       = local_file.ansible_inventory.filename
}

output "ssh_command" {
  description = "SSH command to access the server"
  value       = "ssh root@${hcloud_server.uat.ipv4_address}"
}
