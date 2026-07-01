# Ansible Inventory Repository

This repository serves as the **Single Source of Truth** for your server infrastructure. Use it to manage Linux and Windows hosts with a consistent, template-driven workflow.

## Quick Start

```bash
# Clone the repository
git clone <your-repo-url>
cd <repo-name>

# First-time setup
./run-check.sh

# Create a vault password file (optional, for encrypted inventories)
echo "your-password" > ~/.ansible_vault_pass
chmod 600 ~/.ansible_vault_pass

# Run the playbook
./run-check.sh
```

## Directory Structure

```
├── .gitignore                    # Ignore temporary and sensitive files
├── README.md                     # This file
├── check-infrastructure.yml      # Sanity check playbook
├── production.yml                # Production inventory hosts
├── staging.yml                   # Staging inventory hosts
├── run-check.sh                  # Automated setup + playbook execution
│
├── group_vars/                   # Group-level variables
│   ├── all.yml                   # Global defaults for all hosts
│   ├── linux_servers.yml         # Variables for all Linux servers
│   └── monitoring_servers.yml    # Variables for monitoring servers
│
├── host_vars/                    # Host-specific configurations
│   └── <hostname>.yml            # See templates/ below
│
├── templates/                    # Templates for new hosts
│   └── app-server.yml            # Copy this for new servers
│
└── venv/                         # Python virtual environment (ignored)
```

## Adding a New Server

1. **Copy the template:**
   ```bash
   cp templates/app-server.yml host_vars/<hostname>.yml
   ```

2. **Edit the copied file** with:
   - The host's `ansible_host` (IP or DNS name)
   - Enable required feature flags (exporters, etc.)

3. **Add the host** to `production.yml` or `staging.yml` if needed

## Server Template Structure

Each server configuration consists of two files:

**`<hostname>.yml`** - Public configuration (no secrets):
- `ansible_host` - IP address or DNS name
- Feature flags (`monitoring_node_exporter`, etc.)
- References to vault variables for credentials

**`vault.yml`** - Encrypted secrets file (if needed):
- `vault_user` - SSH login user
- `vault_password` - User password (if using password auth)
- `vault_become_password` - Sudo/admin password

The template in `templates/app-server.yml` starts as a basic template. For servers requiring sudo access, create a corresponding `vault.yml` in the same directory.

## Example Server Setup

```bash
# Create a new server configuration
cp templates/app-server.yml host_vars/my-new-server.yml

# Add to inventory
echo "my-new-server ansible_connection=ssh" >> production.yml

# Create encrypted vault file for credentials (optional)
echo "123" | ansible-vault encrypt host_vars/my-new-server/vault.yml \
    --name vault_user \
    --name vault_password \
    --name vault_become_password
```

## Adding a New Server

1. **Copy the template:**
   ```bash
   cp templates/app-server.yml host_vars/<hostname>.yml
   ```

2. **Edit the copied file** with:
   - The host's `ansible_host` (IP or DNS name)
   - Enable required feature flags (exporters, etc.)

3. **Add the host** to `production.yml` or `staging.yml` if needed

## Template Variables

| Variable | Description |
|----------|-------------|
| `ansible_host` | IP address or DNS name (required) |
| `monitoring_node_exporter` | Enable node exporter monitoring |
| `monitoring_process_exporter` | Enable process exporter monitoring |

## Infrastructure Check & System Report

Run `check-infrastructure.yml` to verify server connectivity, permissions, and collect system information (OS, IP, architecture) for a quick health report.

```bash
./run-check.sh
```

The script will:
1. Create/activate `.venv/` virtual environment
2. Install Ansible and dependencies
3. Run the playbook against `production.yml` or `staging.yml`

For hosts requiring sudo password authentication, create a vault password file first:

```bash
echo "your-password" > ~/.ansible_vault_pass
chmod 600 ~/.ansible_vault_pass
```

The script will automatically detect and use `~/.ansible_vault_pass` (or override via `ANSIBLE_VAULT_PASSWORD_FILE`).

## Sudo Password Management

For hosts requiring sudo access, store credentials securely using Ansible Vault:

```bash
ansible-vault edit host_vars/<hostname>/vault.yml
```

The vault file stores:
- `vault_user` - SSH login user
- `vault_password` - User password (if using password authentication)
- `vault_become_password` - Sudo/admin password

These are referenced in the host's main config file via `{{ vault_* }}` variables.

See `group_vars/all.yml` for the global `ansible_become_password` configuration.

## Usage Scenarios

| Scenario | Command |
|----------|---------|
| First-time setup on a new machine | `./run-check.sh` |
| Run playbook (with vault) | `./run-check.sh` (with vault file) |
| Run playbook (development mode) | `ANSIBLE_VAULT_PASSWORD_FILE="" ./run-check.sh` |
| Override vault file path | `ANSIBLE_VAULT_PASSWORD_FILE=/path/to/password/file ./run-check.sh` |

## Output Example

When running the sanity check, you'll see output like this for each host:

```
TASK [Generate system report (Linux)] ***********************************
ok: [app-server-01] => {
    "msg": [
        "=========================================",
        "HOST:       app-server-01",
        "SSH-USER:   srv_admin_alpha",
        "IP (Ansible): 192.168.1.50",
        "IP (System):  192.168.1.50",
        "OS:         Ubuntu 26.04",
        "ARCH:       x86_64",
        "TYPE:        kvm",
        "=========================================="
    ]
}
```

## Ansible Vault Configuration

The repository uses Ansible Vault to encrypt sensitive data. Passwords are stored in vaulted variables (e.g., `ansible_become_password`) rather than in plaintext inventory files.

## Molecule Integration (Test-Setup)

When using Molecule for testing, ensure containers can collect facts properly:

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
