# ansible-uat

[![CI](https://github.com/nivedmahendran/ansible-uat/actions/workflows/deploy.yml/badge.svg)](https://github.com/nivedmahendran/ansible-uat/actions/workflows/deploy.yml)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![K3s](https://img.shields.io/badge/K3s-v1.35.5-FFC61C?logo=kubernetes)](https://k3s.io)
[![Terraform](https://img.shields.io/badge/Terraform-v1.5+-7B42BC?logo=terraform)](terraform/)

Production-grade UAT environment — bare metal to Kubernetes, GitOps, monitoring, and logging. Everything is defined as code and deployed automatically.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   GitHub Repository                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐ │
│  │ Ansible  │  │   K8s    │  │   Helm   │  │ ArgoCD  │ │
│  │ Playbooks│  │ Manifests│  │  Charts  │  │   App   │ │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬────┘ │
└───────┼──────────────┼──────────────┼──────────────┼─────┘
        │              │              │              │
        ▼              ▼              ▼              ▼
┌──────────────────────────────────────────────────────────────┐
│                    GitHub Actions (CI/CD)                     │
│            On push to main → ansible-playbook deploy.yml      │
└──────────────────────────────┬───────────────────────────────┘
                               │ SSH
                               ▼
┌──────────────────────────────────────────────────────────────┐
│                      UAT Server (63.250.52.122)              │
│  ┌──────────┐   ┌─────────────────────────────────────────┐ │
│  │  Docker  │   │             K3s Cluster                  │ │
│  │ Compose  │   │  ┌──────────┐  ┌──────────┐             │ │
│  │ (Legacy) │   │  │  Flask   │  │  Postgres│             │ │
│  │          │   │  │  App x3  │  │  (PVC)   │             │ │
│  │          │   │  ├──────────┤  ├──────────┤             │ │
│  │          │   │  │ Traefik  │  │  ArgoCD  │             │ │
│  │          │   │  │ Ingress  │  │  GitOps  │             │ │
│  │          │   │  ├──────────┤  ├──────────┤             │ │
│  │          │   │  │cert-man  │  │ Loki +   │             │ │
│  │          │   │  │ ager TLS │  │ Promtail │             │ │
│  │          │   │  ├──────────┤  ├──────────┤             │ │
│  │          │   │  │Prometheus│  │ Grafana  │             │ │
│  │          │   │  └──────────┘  └──────────┘             │ │
│  └──────────┘   └─────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

## Tech Stack

| Category | Tools |
|---|---|
| **Infra Provisioning** | Terraform (Hetzner Cloud) |
| **Config Mgmt** | Ansible 14 + Ansible Vault (secrets) |
| **Container Runtime** | Docker, containerd (K3s) |
| **Orchestration** | K3s v1.35.5, Helm charts |
| **GitOps** | ArgoCD (auto-sync, auto-prune) |
| **CI/CD** | GitHub Actions (lint -> security scan -> deploy) |
| **Ingress/TLS** | Traefik + cert-manager (self-signed CA) |
| **Monitoring** | Prometheus + Grafana (Node Exporter dashboard) |
| **Logging** | Loki + Promtail (Docker + syslog) |
| **Database** | PostgreSQL (persistent via PVC) |
| **App** | Flask + Nginx + Postgres (visitor counter) |
| **Security** | Trivy (K8s config, Dockerfile, Helm) |

## Features

- **IaC end-to-end** — Terraform provisions the VM, Ansible configures it, ArgoCD syncs the cluster
- **CI/CD pipeline** — On push: lint YAML + Ansible, Trivy security scan, then deploy to UAT
- **GitOps** — ArgoCD watches the repo and keeps the cluster in sync
- **Security scanning** — Trivy checks K8s manifests, Dockerfile, and Helm charts for CVEs
- **Auto-scaling** — 3 Flask replicas behind Traefik ingress
- **Persistent storage** — PostgreSQL data survives pod restarts
- **Monitoring** — Prometheus scrapes metrics; Grafana preloaded with Node Exporter dashboard
- **Log aggregation** — Loki centralizes logs from all containers and syslog
- **TLS** — cert-manager issues certificates for HTTPS access

## Services

| Service | URL | Credentials |
|---|---|---|
| App | https://63.250.52.122.nip.io | — |
| Grafana | https://63.250.52.122.nip.io:3000 | admin / admin |
| Prometheus | https://63.250.52.122.nip.io:9090 | — |
| ArgoCD | https://63.250.52.122.nip.io:32050 | admin / VwtBpemCLsRlgK2D |

## Project Structure

```
ansible-uat/
├── .github/workflows/deploy.yml   # CI/CD pipeline
├── app/                            # Flask app source
│   ├── app.py
│   ├── Dockerfile
│   └── requirements.txt
├── k8s/                            # Kubernetes manifests (Kustomize)
│   ├── kustomization.yml
│   ├── namespace.yml
│   ├── deployment-app.yml
│   ├── deployment-db.yml
│   ├── service-app.yml
│   ├── service-db.yml
│   ├── ingress.yml
│   ├── configmap.yml
│   ├── secret.yml
│   ├── pvc.yml
│   └── cluster-issuer.yml
├── terraform/                       # Terraform (Hetzner Cloud provisioning)
├── helm-chart/                     # Helm chart (alternative deploy)
├── Makefile                         # Common commands (deploy, logs, lint)
├── LICENSE                          # MIT license
├── grafana/                        # Grafana provisioning
│   ├── datasources/datasource.yml
│   └── dashboards/
├── prometheus/prometheus.yml       # Prometheus config
├── loki/promtail.yml               # Log shipping config
├── nginx/default.conf              # Nginx reverse proxy config
├── deploy.yml                      # Ansible deployment playbook
├── k3s.yml                         # K3s install playbook
├── certmanager.yml                 # cert-manager install playbook
├── docker.yml                      # Docker install playbook
└── argocd.yml                      # ArgoCD install playbook
```

## Deployment

Any push to `main` triggers:

1. **Lint** — yamllint + ansible-lint
2. **Security scan** — Trivy scans K8s manifests, Dockerfile, Helm charts
3. **Deploy** — Ansible pushes to UAT, ArgoCD syncs the cluster

To provision from scratch:

```bash
# 1. Provision VM (requires Hetzner Cloud token)
cd terraform && terraform init && terraform apply

# 2. Install Docker + K3s + tools
ansible-playbook -i inventory.ini docker.yml
ansible-playbook -i inventory.ini k3s.yml
ansible-playbook -i inventory.ini certmanager.yml
ansible-playbook -i inventory.ini argocd.yml

# 3. Deploy the app
ansible-playbook -i inventory.ini deploy.yml

# Or use the Makefile
make deploy
```
