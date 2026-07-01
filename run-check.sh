#!/bin/bash
set -e

SCRIPT_DIR="$(git rev-parse --show-toplevel)"
cd "$SCRIPT_DIR"

# Run setup (venv, pip, dependencies)
./setup.sh

# Run playbook
./run-playbook.sh
