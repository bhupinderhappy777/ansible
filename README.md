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
├── inventory/
│   └── hosts.ini        # Multi-cloud inventory grouped by environment
├── playbooks/
│   └── ping.yml         # Connection verification suite
├── scripts/
│   └── get_vault_pass.sh # OCI CLI script for dynamic secret retrieval
└── group_vars/          # Encrypted variables via Ansible Vault

```

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

### 📈 Future Roadmap

* [ ] Implement **Docker Swarm** across all ARM nodes for high-availability.
* [ ] Deploy **Firefly III** with automated backups to OCI Object Storage.
* [ ] Integrate **GitHub Actions** for CI/CD linting of playbooks.

---

### 🎓 Academic Context

This project was developed during the **Bachelor of Computer Information Systems (BCIS)** program at the **University of the Fraser Valley (UFV)** to demonstrate advanced competency in Infrastructure as Code (IaC) and Cloud Security.
