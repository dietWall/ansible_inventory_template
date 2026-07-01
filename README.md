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
