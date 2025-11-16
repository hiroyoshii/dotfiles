#!/bin/bash
# Example: How to use external file management with chezmoi

# This file demonstrates the setup and usage of external file management

echo "=== External File Management Example ==="
echo ""

# 1. Set up environment variables
echo "1. Setting environment variables..."
export DEPLOYMENT_TYPE=all
export PROXY_HOST=""  # Set to your proxy if needed
export PROXY_PORT="8080"
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="your.email@example.com"

# 2. Initialize chezmoi (first time setup)
echo ""
echo "2. Initialize chezmoi with dotfiles..."
echo "   Command: chezmoi init --apply https://github.com/hiroyoshii/dotfiles.git"
echo ""
echo "   This will:"
echo "   - Download and install external tools (kubectl, terraform, yq, etc.) to ~/.local/bin"
echo "   - Apply dotfile configurations"
echo "   - Run installation scripts"

# 3. Install system-level configurations (requires sudo)
echo ""
echo "3. Install system configurations (optional, requires sudo)..."
echo "   Command: sudo bash ~/.local/share/chezmoi/run_once_after_install-system-configs.sh"
echo ""
echo "   This will:"
echo "   - Copy network tuning to /etc/sysctl.d/"
echo "   - Copy proxy config to /etc/environment.d/ (if PROXY_HOST is set)"
echo "   - Apply sysctl changes"

# 4. Verify external tools installation
echo ""
echo "4. Verify external tools..."
echo "   Commands to check installed tools:"
echo "   - kubectl version --client"
echo "   - terraform version"
echo "   - yq --version"
echo "   - kind version"

# 5. Update external tools
echo ""
echo "5. Update external tools..."
echo "   Command: chezmoi apply --force ~/.local/bin/"
echo ""
echo "   This will re-download all external tools"

# 6. Check what files are managed
echo ""
echo "6. Check managed files..."
echo "   Command: chezmoi managed"

# 7. View differences before applying
echo ""
echo "7. Preview changes..."
echo "   Command: chezmoi diff"

echo ""
echo "=== Directory Structure ==="
echo ""
echo "dotfiles/"
echo "├── .chezmoiexternal.yaml.tmpl    # External binary downloads"
echo "├── etc/                           # System configs (not auto-applied)"
echo "│   ├── sysctl.d/                 # Kernel parameters"
echo "│   └── environment.d/            # System env vars"
echo "├── home/                          # Reference for home structure"
echo "│   └── .local/bin/               # User binaries (auto-installed)"
echo "└── run_once_after_*.sh.tmpl      # Installation scripts"

echo ""
echo "=== Deployment Types ==="
echo ""
echo "DEPLOYMENT_TYPE=all      - All tools (kubectl, terraform, lazydocker, etc.)"
echo "DEPLOYMENT_TYPE=cloud    - Cloud tools (kubectl, terraform, helm, stern)"
echo "DEPLOYMENT_TYPE=edge     - Edge tools (docker, lazydocker, ctop)"
echo "DEPLOYMENT_TYPE=onprem   - On-prem tools (ansible, ansible-lint)"

echo ""
echo "For more details, see:"
echo "- EXTERNAL_TOOLS.md - External tools documentation"
echo "- README.md         - Main documentation"
echo "- TESTING.md        - Testing guide"
