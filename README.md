# Ansible Inventory Repository

This repository serves as the **Single Source of Truth** for the server infrastructure.

## Directory Structure

```
├── .gitignore                    # Ignore temporary and sensitive files
├── README.md                     # This file
├── production.yml                # Production inventory hosts
├── staging.yml                   # Staging inventory hosts
│
├── group_vars/                   # Group-level variables
│   ├── all.yml                   # Global defaults for all hosts
│   ├── linux_servers.yml         # Variables for all Linux servers
│   └── monitoring_servers.yml    # Variables for monitoring servers
│
├── host_vars/                    # Host-specific configurations
│   ├── <hostname>.yml            # Individual host files (see template below)
│   │
└── templates/                    # Templates for new hosts
    └── app-server.yml            # Copy this template for new servers
```

## Adding a New Server

1. **Copy the template:**
   ```bash
   cp templates/app-server.yml host_vars/<hostname>.yml
   ```

2. **Edit the copied file** with:
   - The host's IP address or DNS name
   - Enable required feature flags (exporters, etc.)

3. **Add the host** to `production.yml` or `staging.yml` if needed

## Template Variables

- `ansible_host` - IP address or DNS name (required)
- `monitoring_node_exporter` - Enable node exporter monitoring
- `monitoring_process_exporter` - Enable process exporter monitoring

## Infrastructure Check & System Report

Run `check-infrastructure.yml` to verify server connectivity, permissions, and collect system information (OS, IP, architecture) for a quick health report.

```bash
ansible-playbook -i production.yml check-infrastructure.yml [-K]
```

Add `-K` if your hosts require sudo password authentication.

## Sudo Password Management

For hosts requiring sudo access, store the password securely using Ansible Vault:

```bash
ansible-vault edit group_vars/all.yml
```

See `group_vars/all.yml` for the `ansible_become_password` configuration.

## Running the Sanity Check

The `run-check.sh` script automates the setup and execution of the infrastructure check:

1. Creates a Python virtual environment (`.venv/`)
2. Installs Ansible and dependencies
3. Runs `check-infrastructure.yml` against your inventory

```bash
# Create venv, install deps, and run the playbook
./run-check.sh
```

For encrypted inventories, create a vault password file first:

```bash
echo "your-password" > ~/.ansible_vault_pass
chmod 600 ~/.ansible_vault_pass
```

The script will automatically detect and use `~/.ansible_vault_pass` (or override via `ANSIBLE_VAULT_PASSWORD_FILE`).
