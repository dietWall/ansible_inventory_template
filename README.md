# Infrastructure Inventory Repository

This repository serves as the **Single Source of Truth** for your infrastructure.

It contains inventories, host variables, group variables, and encrypted secrets while intentionally excluding automation logic.

Keeping infrastructure definitions separate from playbooks and roles allows the same inventory to be reused across multiple automation projects while maintaining a clean separation of responsibilities.

---

# Repository Structure

```text
.
├── production.yml
├── staging.yml
├── check-infrastructure.yml
├── run-check.sh
├── group_vars/
│   ├── all.yml
│   └── ...
├── host_vars/
│   └── your_server/
│       ├── your_server.yml
│       └── vault.yml
└── README.md
```

## Directory Overview

| Path                       | Purpose                                    |
| -------------------------- | ------------------------------------------ |
| `group_vars/`              | Variables shared by host groups            |
| `host_vars/`               | Host-specific configuration                |
| `production.yml`           | Production inventory                       |
| `staging.yml`              | Staging inventory                          |
| `check-infrastructure.yml` | Validation playbook                        |
| `run-check.sh`             | Helper script for validating the inventory |

---

# Design Principles

This repository intentionally contains **only infrastructure data**.

Automation code, roles, Molecule scenarios, and deployment logic belong in separate repositories.

This separation provides several benefits:

* inventories evolve independently from automation
* multiple automation projects can reuse the same inventory
* infrastructure changes remain independent from automation code
* secrets remain isolated from the automation repositories

---

# Host Structure

Each managed host has its own directory inside `host_vars/`.

The repository follows the convention that the primary variable file has the same name as the inventory hostname.

Example:

```text
host_vars/
└── your_server/
    ├── your_server.yml
    └── vault.yml
```

Where:

* `your_server.yml` contains all non-sensitive host configuration.
* `vault.yml` contains encrypted credentials and other confidential information.

This naming convention allows playbooks to locate the correct host configuration dynamically:

```yaml
file: "{{ lookup('env', 'MOLECULE_HOST_VARS_DIR') }}/{{ inventory_hostname }}/{{ inventory_hostname }}.yml"
```

No host-specific paths need to be hardcoded into the automation.

The reference host `your_server` is also used by the accompanying `ansible_foundation` project. During the Molecule demonstration, a container with the hostname `your_server` is created, configured, and managed using exactly the same inventory structure. This makes the reference host both executable documentation and a template for new systems.

---

# Vault Password

For demonstration purposes, the repository may include a default Vault password.

When adapting the inventory for your own infrastructure, you should replace it with your own Vault password.

A recommended approach is to store the password in a local file that is excluded from Git:

```bash
echo "my-secure-vault-password" > .vault-password
chmod 600 .vault-password
```

Configure Ansible to use it:

```bash
export ANSIBLE_VAULT_PASSWORD_FILE=.vault-password
```

The password file should never be committed to version control.

---

# Getting Started

Validate the inventory by running:

```bash
ANSIBLE_VAULT_PASSWORD_FILE=.vault-password ./run-check.sh
```

The helper script automatically:

* creates a local Python virtual environment if required
* installs the necessary Ansible dependencies
* executes the validation playbook

---

# Adding a New Host

Create a new host by copying the reference host:

```bash
cp -r host_vars/your_server host_vars/web01
mv host_vars/web01/your_server.yml host_vars/web01/web01.yml
```

Then:

1. Adjust `web01.yml` to match the new host.
2. Update the encrypted credentials in `vault.yml`.
3. Add the new host to the desired inventory.

---

# Initial Server Provisioning

The inventory contains the information required for the initial connection to a newly installed server.

Depending on the target environment, this may be:

* a temporary password
* an existing SSH key
* another supported authentication method

During the initial provisioning process, the automation typically:

* connects to the server
* creates the administrative user
* installs and configures OpenSSH
* deploys the administrator's SSH public key
* configures privilege escalation

After these steps have been completed successfully, the server can be administered using SSH key authentication for all subsequent Ansible runs.

---

# Validation

The included validation playbook verifies that:

* inventory files are syntactically correct
* encrypted Vault files can be decrypted
* host variables are loaded correctly
* inventory definitions are complete

Run

```bash
ANSIBLE_VAULT_PASSWORD_FILE=.vault-password ./run-check.sh
```

before committing infrastructure changes.

---

# Relationship to Automation Repositories

This repository intentionally contains **only infrastructure definitions**.

Automation repositories reference this inventory as a Git submodule.

Using the same inventory during development, testing, and production helps ensure that automation is always validated against realistic infrastructure definitions rather than simplified test inventories.

This architecture allows infrastructure data and automation code to evolve independently while remaining fully compatible with each other.
