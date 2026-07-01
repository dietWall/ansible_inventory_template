# Ansible Inventory Repository

This repository serves as the **Single Source of Truth** for your server infrastructure. Use it to manage Linux and Windows hosts with a consistent, template-driven workflow.

## Directory Structure

```text
.
|-- .gitignore
|-- README.md
|-- check-infrastructure.yml
|-- production.yml
|-- staging.yml
|-- run-check.sh
|
|-- group_vars/

|   |-- all.yml
|   |-- linux_servers.yml
|   `-- monitoring_servers.yml
|
|-- host_vars/
|   `-- <hostname>/

|       |-- klartext.yml
|       `-- vault.yml
|
|-- templates/
|   `-- host-folder/

|       |-- klartext.yml
|       `-- vault.yml
`-- venv/
```

- **check-infrastructure.yml**: Sanity check playbook and system report.
- **host_vars/`<hostname>`/**: Dedicated folder per host containing public and secret vars.
- **templates/host-folder/**: Template blueprints to add new servers.

## Quick Start / First-Time Setup

1. **Configure Vault Password:**
   Store your master vault password locally (this file is ignored by git):
   ```bash
   echo "your-vault-password" > ~/.zeus-lat-vault-pass
   chmod 600 ~/.zeus-lat-vault-pass
   ```

2. **Run Infrastructure Check:**
   ```bash
   ANSIBLE_VAULT_PASSWORD_FILE=~/.zeus-lat-vault-pass ./run-check.sh
   ```
   The script automatically sets up the Python Virtual Environment (`venv/`), installs Ansible, and runs the sanity check.

## Adding a New Server

1. **Copy the template folder:**
   ```bash
   cp -r templates/host-folder host_vars/<hostname>
   ```

2. **Configure Public Data (`host_vars/<hostname>/klartext.yml`):**
   Set the `ansible_host` (IP or DNS) and enable required feature flags:
   ```yaml
   ---
   ansible_host: 192.168.1.50
   
   ansible_user: "{{ vault_ssh_user }}"
   ansible_password: "{{ vault_ssh_password }}"
   ansible_become_password: "{{ vault_ssh_password }}"
   
   monitoring_node_exporter: true
   monitoring_process_exporter: false
   monitoring_windows_exporter: false
   ```

3. **Configure Encrypted Secrets (`host_vars/<hostname>/vault.yml`):**
   Edit your secrets and encrypt the file with your specific vault-id:
   ```bash
   # To edit an existing file:
   ansible-vault edit --vault-id <hostname>@prompt host_vars/<hostname>/vault.yml
   ```
   Structure inside `vault.yml`:
   ```yaml
   ---
   vault_ssh_user: "zeus"
   vault_ssh_password: "secure_password"
   ```

4. **Add the host** to `production.yml` or `staging.yml`.

## Template Variables

| Variable | Description |
|----------|-------------|
| `ansible_host` | IP address or DNS name (required) |
| `monitoring_node_exporter` | Enable node exporter monitoring (true/false) |
| `monitoring_process_exporter` | Enable process exporter monitoring (true/false) |
| `monitoring_windows_exporter` | Enable windows exporter monitoring (true/false) |

## Usage Scenarios

| Scenario | Command |
|----------|---------|
| Standard production run | `ANSIBLE_VAULT_PASSWORD_FILE=~/.zeus-lat-vault-pass ./run-check.sh` |
| Development mode (No Vault) | `ANSIBLE_VAULT_PASSWORD_FILE="" ./run-check.sh` |

## Molecule Integration (Test-Setup inside Code Repo)

Keep Molecule in your role/code repository. Ensure the containers can collect facts by providing the required packages and mock variables in `molecule.yml`:

```yaml
platforms:
  - name: ubuntu2604-test-host
    image: ubuntu:26.04
    pkg_extras:
      - python3
      - iproute2
    vars:
      monitoring_node_exporter: true
      monitoring_process_exporter: true
      monitoring_windows_exporter: false
```
