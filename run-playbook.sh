#!/bin/bash
set -e

SCRIPT_DIR="$(git rev-parse --show-toplevel)"
cd "$SCRIPT_DIR"

# Activate virtual environment
echo "=== Activating virtual environment ==="
source .venv/bin/activate

# Vault password file path (defaults to $HOME/.ansible_vault_pass)
VAULT_PASSWORD_FILE="${ANSIBLE_VAULT_PASSWORD_FILE:-$HOME/.ansible_vault_pass}"

if [ -f "$VAULT_PASSWORD_FILE" ]; then
    echo "=== Running playbook with Ansible Vault (password file: $VAULT_PASSWORD_FILE) ==="
    chmod 600 "$VAULT_PASSWORD_FILE"  # Ensure file is not world-readable
    export ANSIBLE_VAULT_PASSWORD_FILE="$VAULT_PASSWORD_FILE"
    ansible-playbook -i production.yml check-infrastructure.yml
else
    echo "=== Running playbook without encryption (development mode) ==="
    ansible-playbook -i production.yml check-infrastructure.yml
fi

echo ""
echo "=== Playbook run complete! ==="
