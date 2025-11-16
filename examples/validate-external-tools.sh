#!/bin/bash
# Validation script for external file management setup

set -e

echo "=== Validating External File Management Setup ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() {
    echo -e "${GREEN}✓${NC} $1"
}

fail() {
    echo -e "${RED}✗${NC} $1"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check if ~/.local/bin is in PATH
echo "1. Checking PATH configuration..."
if [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
    pass "~/.local/bin is in PATH"
else
    fail "~/.local/bin is NOT in PATH"
    echo "   Add to ~/.bashrc: export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# Check if directory exists
echo ""
echo "2. Checking directory structure..."
if [ -d "$HOME/.local/bin" ]; then
    pass "~/.local/bin directory exists"
else
    fail "~/.local/bin directory does not exist"
    echo "   Run: mkdir -p ~/.local/bin"
fi

# Check for external tools based on deployment type
echo ""
echo "3. Checking external tools installation..."
DEPLOYMENT_TYPE=${DEPLOYMENT_TYPE:-all}
echo "   Deployment type: $DEPLOYMENT_TYPE"

# Tools for all/cloud deployments
if [[ "$DEPLOYMENT_TYPE" == "all" || "$DEPLOYMENT_TYPE" == "cloud" ]]; then
    for tool in kubectl terraform yq kind; do
        if command -v $tool &> /dev/null; then
            pass "$tool is installed ($(command -v $tool))"
        else
            warn "$tool is NOT installed"
        fi
    done
fi

# Tools for all/cloud/edge deployments
if [[ "$DEPLOYMENT_TYPE" == "all" || "$DEPLOYMENT_TYPE" == "cloud" || "$DEPLOYMENT_TYPE" == "edge" ]]; then
    for tool in lazydocker dive ctop; do
        if command -v $tool &> /dev/null; then
            pass "$tool is installed ($(command -v $tool))"
        else
            warn "$tool is NOT installed"
        fi
    done
fi

# Tools for all/onprem deployments
if [[ "$DEPLOYMENT_TYPE" == "all" || "$DEPLOYMENT_TYPE" == "onprem" ]]; then
    for tool in ansible-lint ansible-navigator; do
        if command -v $tool &> /dev/null; then
            pass "$tool is installed ($(command -v $tool))"
        else
            warn "$tool is NOT installed"
        fi
    done
fi

# Check system configurations
echo ""
echo "4. Checking system configurations..."

# Network tuning
if [ -f "/etc/sysctl.d/99-network-tuning.conf" ]; then
    pass "Network tuning configuration is installed"
    # Check if applied
    if sudo sysctl net.core.rmem_max | grep -q "16777216"; then
        pass "Network tuning is applied"
    else
        warn "Network tuning is installed but not applied. Run: sudo sysctl --system"
    fi
else
    warn "Network tuning configuration is NOT installed"
    echo "   Run: sudo bash ~/.local/share/chezmoi/run_once_after_install-system-configs.sh"
fi

# Proxy configuration (if PROXY_HOST is set)
if [ -n "$PROXY_HOST" ]; then
    if [ -f "/etc/environment.d/proxy.conf" ]; then
        pass "System-wide proxy configuration is installed"
    else
        warn "PROXY_HOST is set but system proxy config is NOT installed"
        echo "   Run: sudo bash ~/.local/share/chezmoi/run_once_after_install-system-configs.sh"
    fi
else
    echo "   PROXY_HOST not set, skipping proxy configuration check"
fi

# Check chezmoi source directory
echo ""
echo "5. Checking chezmoi setup..."
if [ -d "$HOME/.local/share/chezmoi" ]; then
    pass "chezmoi source directory exists"
    
    # Check if external tools are defined
    if [ -f "$HOME/.local/share/chezmoi/.chezmoiexternal.yaml" ]; then
        pass "External tools configuration exists"
    else
        warn "External tools configuration does NOT exist"
    fi
    
    # Check directory structure
    if [ -d "$HOME/.local/share/chezmoi/etc" ]; then
        pass "etc/ directory exists in source"
    else
        fail "etc/ directory does NOT exist in source"
    fi
    
    if [ -d "$HOME/.local/share/chezmoi/home" ]; then
        pass "home/ directory exists in source"
    else
        fail "home/ directory does NOT exist in source"
    fi
else
    fail "chezmoi source directory does NOT exist"
    echo "   Run: chezmoi init https://github.com/hiroyoshii/dotfiles.git"
fi

echo ""
echo "=== Validation Complete ==="
echo ""
echo "Summary:"
echo "- If you see ✗ (red X), there's an issue that needs to be fixed"
echo "- If you see ⚠ (yellow warning), the feature may not be installed or configured"
echo "- If you see ✓ (green check), everything is working correctly"
echo ""
echo "For more information, see:"
echo "- EXTERNAL_TOOLS.md - External tools documentation"
echo "- README.md - Main documentation"
echo "- TESTING.md - Testing guide"
