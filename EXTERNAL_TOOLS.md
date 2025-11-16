# External Tools and Files Management

This directory structure manages external files and tools that are:
- Not installed via apt/package managers
- System-level configuration files (in `/etc`)
- Manually downloaded binaries

## Directory Structure

```
dotfiles/
├── etc/                           # System-level configuration files
│   ├── sysctl.d/                 # Kernel parameter tuning
│   │   └── 99-network-tuning.conf
│   └── environment.d/            # System-wide environment variables
│       └── proxy.conf.tmpl
├── home/                          # Reserved for future home directory files
│   └── .local/
│       └── bin/                  # User-level binaries (managed by .chezmoiexternal.yaml)
└── .chezmoiexternal.yaml.tmpl    # External binary downloads configuration
```

## External Binaries

External binaries are managed through `.chezmoiexternal.yaml.tmpl`. This file defines which tools to download and install automatically.

### Managed Tools

#### All/Cloud Deployment Types:
- **kubectl** - Kubernetes command-line tool
- **terraform** - Infrastructure as Code tool
- **yq** - YAML processor
- **kind** - Kubernetes in Docker
- **kubectx/kubens** - Kubernetes context and namespace switchers
- **k9s** - Kubernetes CLI UI
- **stern** - Multi pod log tailing

#### All/Edge/Cloud Deployment Types:
- **lazydocker** - Docker terminal UI
- **dive** - Docker image explorer
- **ctop** - Container metrics viewer

#### All/Onprem Deployment Types:
- **ansible-lint** - Ansible playbook linter
- **ansible-navigator** - Ansible TUI

### How It Works

1. **Automatic Downloads**: chezmoi downloads binaries from GitHub releases or official URLs
2. **Installation Location**: Binaries are installed to `~/.local/bin`
3. **Auto-Update**: Tools are refreshed weekly (168h refresh period)
4. **Architecture Detection**: Automatically detects AMD64 or ARM64 architecture

### Adding New External Tools

To add a new external tool, edit `.chezmoiexternal.yaml.tmpl`:

```yaml
".local/bin/your-tool":
  type: file  # or archive-file for .tar.gz/.zip
  url: "https://example.com/releases/your-tool-linux-amd64"
  executable: true
  refreshPeriod: 168h
```

## System-Level Configuration Files

System configuration files in the `etc/` directory are NOT automatically installed by chezmoi (they require sudo privileges). Instead, they are installed by the `run_once_after_install-system-configs.sh.tmpl` script.

### Network Tuning (`etc/sysctl.d/99-network-tuning.conf`)

Optimizes TCP/IP stack for better network performance:
- Increased TCP buffer sizes
- TCP window scaling
- TCP fast open
- Low latency optimization

**Installation:**
```bash
# The script handles installation automatically
# Or manually:
sudo cp etc/sysctl.d/99-network-tuning.conf /etc/sysctl.d/
sudo sysctl --system
```

### System-Wide Proxy (`etc/environment.d/proxy.conf.tmpl`)

Sets proxy environment variables for all users system-wide. Only generated when `PROXY_HOST` is set.

**Installation:**
```bash
# The script handles installation automatically
# Or manually:
sudo cp etc/environment.d/proxy.conf /etc/environment.d/
```

## Manual Installation Scripts

### `run_once_after_install-external-tools.sh.tmpl`

Installs additional tools that require custom installation logic:
- Downloads from GitHub releases
- Extracts archives
- Sets permissions
- Handles architecture detection

### `run_once_after_install-system-configs.sh.tmpl`

Installs system-level configuration files:
- Copies files to `/etc`
- Sets proper permissions (requires sudo)
- Applies sysctl changes

## Usage Examples

### Install Everything

```bash
# Set environment variables
export DEPLOYMENT_TYPE=all
export PROXY_HOST=proxy.example.com  # Optional

# Apply dotfiles (this will also install external tools)
chezmoi init --apply https://github.com/hiroyoshii/dotfiles.git
```

### Install System Configurations

```bash
# Run the system config installation script (requires sudo)
sudo bash ~/.local/share/chezmoi/run_once_after_install-system-configs.sh
```

### Manual External Tool Installation

```bash
# Run the external tools installation script
bash ~/.local/share/chezmoi/run_once_after_install-external-tools.sh
```

### Update External Tools

```bash
# Force re-download of external binaries
chezmoi apply --force

# Or update individual tools
chezmoi apply --force ~/.local/bin/kubectl
```

## Deployment Type Support

| Tool | all | edge | cloud | onprem |
|------|-----|------|-------|--------|
| kubectl | ✓ | ✗ | ✓ | ✗ |
| terraform | ✓ | ✗ | ✓ | ✗ |
| yq | ✓ | ✗ | ✓ | ✗ |
| kind | ✓ | ✗ | ✓ | ✗ |
| kubectx/kubens | ✓ | ✗ | ✓ | ✗ |
| k9s | ✓ | ✗ | ✓ | ✗ |
| stern | ✓ | ✗ | ✓ | ✗ |
| lazydocker | ✓ | ✓ | ✓ | ✗ |
| dive | ✓ | ✓ | ✓ | ✗ |
| ctop | ✓ | ✓ | ✓ | ✗ |
| ansible-lint | ✓ | ✗ | ✗ | ✓ |
| ansible-navigator | ✓ | ✗ | ✗ | ✓ |

## Troubleshooting

### External tools not downloading

```bash
# Check chezmoi external status
chezmoi verify

# Re-download with verbose output
chezmoi apply --force --verbose ~/.local/bin/
```

### System configs not installed

```bash
# Check if running with sudo
sudo bash -c 'echo "Has sudo access"'

# Manually run the installation script
sudo bash ~/.local/share/chezmoi/run_once_after_install-system-configs.sh
```

### PATH not including ~/.local/bin

```bash
# Add to PATH temporarily
export PATH="$HOME/.local/bin:$PATH"

# Permanently add (already in .bashrc template)
source ~/.bashrc
```

## Security Considerations

1. **Binary Downloads**: Tools are downloaded from official GitHub releases or trusted sources
2. **Checksum Verification**: Consider adding checksum verification for critical tools
3. **HTTPS Only**: All downloads use HTTPS URLs
4. **Permission Model**: System files require explicit sudo access
5. **Regular Updates**: Weekly refresh ensures security patches are applied

## Future Enhancements

- [ ] Add checksum verification for downloaded binaries
- [ ] Support for additional package managers (snap, flatpak)
- [ ] More system-level configuration examples
- [ ] Automatic version detection for external tools
- [ ] Integration with version managers (nvm, pyenv, rbenv)
