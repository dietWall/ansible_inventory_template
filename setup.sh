#!/bin/bash
set -e

SCRIPT_DIR="$(git rev-parse --show-toplevel)"
cd "$SCRIPT_DIR"

echo "=== Setup: Cleaning up existing virtual environment ==="
if [ -d ".venv" ]; then
    echo "Removing existing .venv directory..."
    rm -rf .venv
    echo "Cleaned up .venv"
fi

echo "=== Setup: Creating Python virtual environment ==="
python3 -m venv .venv
echo "Virtual environment created"

echo "=== Setup: Activating virtual environment ==="
source .venv/bin/activate

echo "=== Setup: Upgrading pip ==="
pip install --upgrade pip

echo "=== Setup: Installing dependencies ==="
pip install ansible ansible-lint

echo ""
echo "=== Setup complete! ==="
