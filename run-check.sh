#!/bin/bash
set -e

# Get repository root using git
SCRIPT_DIR="$(git rev-parse --show-toplevel)"
cd "$SCRIPT_DIR"

# Step 1: Create virtual environment
echo "=== Creating Python virtual environment ==="
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi

# Step 2: Activate virtual environment
echo "=== Activating virtual environment ==="
source .venv/bin/activate

# Step 3: Upgrade pip and install dependencies
echo "=== Upgrading pip and installing dependencies ==="
pip install --upgrade pip
pip install ansible ansible-lint

# Step 4: Run playbook with Ansible Vault
# Vault password file path (defaults to $HOME/.ansible_vault_pass)
VAULT_PASSWORD_FILE="${ANSIBLE_VAULT_PASSWORD_FILE:-$HOME/.ansible_vault_pass}"

if [ -f "$VAULT_PASSWORD_FILE" ]; then
    echo "=== Running playbook with Ansible Vault (password file: $VAULT_PASSWORD_FILE) ==="
    chmod 600 "$VAULT_PASSWORD_FILE"  # Ensure file is not world-readable
    export ANSIBLE_VAULT_PASSWORD_FILE="$VAULT_PASSWORD_FILE"
    ansible-playbook -i production.yml check-infrastructure.yml
else
    echo "=== Running playbook without encryption (development mode) ==="
    echo "No vault password file found at: $VAULT_PASSWORD_FILE"
    ansible-playbook -i production.yml check-infrastructure.yml
fi

echo ""
echo "=== Check complete! ==="
