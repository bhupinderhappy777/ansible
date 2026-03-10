## 2026 Hybrid-Cloud Automation Project

### OCI & Home-Lab Infrastructure with Ansible

This repository contains the configuration and playbooks for managing a distributed infrastructure across **Oracle Cloud Infrastructure (OCI)** and a **Local Home-Lab** environment.

### 🛠 Technology Stack

* **Infrastructure:** OCI ARM-based Instances (Ubuntu 24.04).
* **Networking:** **Tailscale (WireGuard)** Mesh VPN for secure cross-cloud communication.
* **Configuration Management:** **Ansible** (Playbooks, Roles, and Inventory).
* **Security:** * **OCI Vault:** Dynamic retrieval of Ansible Vault passwords.
* **SSH:** Ed25519 Elliptic Curve cryptography.
* **IAM:** Least-privilege policies for Secret Management.


---

### 🔐 Security Architecture

#### OCI Vault Integration

Instead of storing sensitive passwords in plain text or manual entry, this setup uses a custom **Password Client** script.

* The script uses the **OCI CLI** to fetch the encrypted Ansible Vault password directly from the **OCI Secret Management** service.
* **Authentication:** Secured via OCI API Keys with restricted IAM policies.

#### SSH Key Management

Standardized **Ed25519** keys are used across the entire fleet. To ensure portability between Windows (Development) and Linux (Management Node), keys were synchronized using **Base64 encoding** to prevent line-ending (CRLF/LF) corruption.

---

### 📂 Project Structure

```text
ansible/
├── ansible.cfg          # Optimized with vault_password_file & host_key_checking
├── inventory/           # Host definitions and group variables
├── playbooks/           # All playbooks (site, security, setup, etc.)
│   └── ping.yml         # Connection verification suite
├── scripts/             # Support scripts and automation utilities
│   └── get_vault_pass.sh # OCI CLI script for dynamic secret retrieval
├── roles/               # Modular components for system configuration
└── group_vars/          # Encrypted variables via Ansible Vault
```

### 🛠 Recent Improvements (2026 Overhaul)
- **Standardized Handlers:** Unified SSH and Firewall handlers across the entire codebase.
- **Native Package Management:** Improved Tailscale installation using official repositories instead of shell scripts.
- **Enhanced Validation:** Added `validate` checks for `sshd_config` and `sudoers` files.
- **FQCN Usage:** Transitioned to Fully Qualified Collection Names (e.g., `ansible.builtin.service`) for better long-term compatibility.

---

### 🚀 Getting Started

#### 1. Environment Variables

The password retrieval script requires your Secret OCID to be set in your environment:

```bash
export ANSIBLE_SECRET_OCID="ocid1.vaultsecret.oc1..."

```

#### 2. Inventory Configuration

The inventory uses **Tailscale IPs** for all nodes to ensure encrypted transit between the cloud and the local lab. `ociubuntu` acts as a decentralized controller that can manage itself and other nodes via SSH loopback.

#### 3. Execution

To verify the connectivity of the entire cluster:

```bash
ansible-playbook playbooks/ping.yml

```

---

### 📈 Future Roadmap (DevSecOps Engineering Evolution)

We are evolving this project into a full-fledged production-ready DevSecOps ecosystem, emphasizing modularity, Infrastructure as Code (IaC), zero-trust networking, and shift-left security principles across multiple specialized repositories.

#### 1. Infrastructure Provisioning (Terraform Repo)
*   **Multi-Cloud Architecture**: Create a dedicated **Terraform** repository to provision at least 4 VMs across various cloud providers (e.g., OCI, AWS, Azure) and local Home Labs.
*   **IaC Security Posure**: Integrate static analysis tools (like `tfsec`, `checkov`, or `trivy`) to ensure infrastructure is provisioned securely out-of-the-box.
*   **Cloud Firewalls**: Provision restrictive Security Lists/Groups, exposing *only* essential ports (like the Tailscale UDP port) to the public internet, completely dropping public SSH access.

#### 2. Configuration Management & Security Hardening (Ansible Repo - Current)
*   **Zero-Trust Identity**: Automate Tailscale/WireGuard mesh network configurations for secure, decentralized access across boundaries.
*   **OS Hardening**: Enforce CIS benchmarks, strict SSH policies, automated OS patch management, and automated incident response tools.
*   **Advanced Secret Management**: Deepen integration with modern secret managers (OCI Vault, HashiCorp Vault, SOPS) to completely remove plain-text variables from Git history.
*   **Pre-Flight Security**: Expand on existing local testing with Molecule, linting via `ansible-lint`, and checking playbook idempotence.

#### 3. Container Orchestration & Observability (Docker & K3s Repos)
*   **Container Runtime & Orchestration**: Spin up dedicated repositories configuring **K3s** (lightweight Kubernetes) and **Docker** Swarm/Standalone setups as the primary deployment fabric.
*   **Zero-Day Observability**: Deploy a comprehensive observability stack (Prometheus, Grafana, Loki, ELK) for real-time monitoring, metrics collection, distributed tracing, and incident alerting.
*   **Cluster Security**: Enforce runtime security, container vulnerability scanning, and restrictive network policies (e.g., Calico/Cilium) across the Home Lab K3s clusters.

#### 4. Application Deployment & CI/CD Pipelines (Firefly III Fork)
*   **CI/CD Automation**: Fork the **Firefly III** repository and build a complete CI/CD pipeline using **GitHub Actions** and self-hosted **GitHub Agents** running within our hardened K3s/Docker environment.
*   **Shift-Left Security**: Embed continuous security testing in the pipeline, including SAST/DAST, dependency scanning (Dependabot/Renovate), and secret detection.
*   **Immutable Deployments**: Automate the creation of signed and scanned Docker images for Firefly III. Deploy them to the K3s/Docker home lab using modern GitOps tools and strategies (e.g., ArgoCD, Flux).

---

### 🎓 Academic Context

This project was developed during the **Bachelor of Computer Information Systems (BCIS)** program at the **University of the Fraser Valley (UFV)** to demonstrate advanced competency in Infrastructure as Code (IaC) and Cloud Security.
