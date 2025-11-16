# System-Level Configuration Files

This directory contains system-level configuration files that require root/sudo access to install.

## Purpose

The `etc/` directory mirrors the `/etc` directory structure for:
- System-wide configurations
- Kernel parameters
- Environment variables for all users

## Current Structure

```
etc/
├── sysctl.d/
│   └── 99-network-tuning.conf      # Network optimization
└── environment.d/
    └── proxy.conf.tmpl             # System-wide proxy settings
```

## Installation

These files are **NOT** automatically applied by chezmoi (they're in `.chezmoiignore`). 
They are installed by the `run_once_after_install-system-configs.sh.tmpl` script.

### Automatic Installation

```bash
# Script runs automatically after chezmoi apply (if you have sudo)
sudo bash ~/.local/share/chezmoi/run_once_after_install-system-configs.sh
```

### Manual Installation

```bash
# Network tuning
sudo cp etc/sysctl.d/99-network-tuning.conf /etc/sysctl.d/
sudo sysctl --system

# Proxy configuration (if PROXY_HOST is set)
sudo cp etc/environment.d/proxy.conf /etc/environment.d/
```

## Available Configurations

### Network Tuning (`sysctl.d/99-network-tuning.conf`)

Optimizes TCP/IP stack for:
- Increased buffer sizes
- Better throughput
- Lower latency
- More concurrent connections

**Applies to**: `all`, `cloud`, `edge` deployment types

### System-Wide Proxy (`environment.d/proxy.conf.tmpl`)

Sets proxy environment variables for all users system-wide.

**Applies to**: `all`, `cloud` deployment types (when `PROXY_HOST` is set)

## Adding New System Configurations

1. Create the file in the appropriate subdirectory under `etc/`
2. Add installation logic to `run_once_after_install-system-configs.sh.tmpl`
3. Document the configuration in this README

## Security Considerations

- All files should have appropriate permissions (typically 644)
- Sensitive information should not be hardcoded
- Use templates (`.tmpl`) for files with dynamic content
- Test changes in a safe environment first

## See Also

- [EXTERNAL_TOOLS.md](../EXTERNAL_TOOLS.md) - External tools and binaries management
- [README.md](../README.md) - Main documentation
