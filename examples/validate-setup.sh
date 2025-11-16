#!/bin/bash
# Validation script to check if dotfiles are properly applied

set -e

echo "=== Dotfiles Validation Script ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track results
PASSED=0
FAILED=0
WARNINGS=0

# Helper functions
check_file() {
    local file=$1
    local name=$2
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $name exists: $file"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $name missing: $file"
        ((FAILED++))
        return 1
    fi
}

check_command() {
    local cmd=$1
    local name=$2
    if command -v $cmd &> /dev/null; then
        version=$($cmd --version 2>&1 | head -n1)
        echo -e "${GREEN}✓${NC} $name installed: $version"
        ((PASSED++))
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $name not installed"
        ((WARNINGS++))
        return 1
    fi
}

check_env_var() {
    local var=$1
    local name=$2
    if [ -n "${!var}" ]; then
        echo -e "${GREEN}✓${NC} $name set: ${!var}"
        ((PASSED++))
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $name not set"
        ((WARNINGS++))
        return 1
    fi
}

echo "Deployment Type: ${DEPLOYMENT_TYPE:-not set}"
echo ""

# Check core files
echo "=== Core Configuration Files ==="
check_file ~/.gitconfig "Git config"
check_file ~/.bashrc "Bash config"
check_file ~/.proxy_env "Proxy env" || true

echo ""
echo "=== Deployment-Specific Files ==="

case "${DEPLOYMENT_TYPE:-all}" in
    all)
        echo "Checking for ALL deployment type..."
        check_file ~/.docker/config.json "Docker config"
        check_file ~/.goproxy "Go proxy"
        check_file ~/.helmrc "Helm config"
        check_file ~/.ssh/config "SSH config"
        check_file ~/.ansible.cfg "Ansible config"
        ;;
    edge)
        echo "Checking for EDGE deployment type..."
        check_file ~/.docker/config.json "Docker config"
        check_file ~/.goproxy "Go proxy"
        check_file ~/.ssh/config "SSH config"
        ! [ -f ~/.helmrc ] && echo -e "${GREEN}✓${NC} Helm config correctly excluded" || echo -e "${RED}✗${NC} Helm config should be excluded"
        ! [ -f ~/.ansible.cfg ] && echo -e "${GREEN}✓${NC} Ansible config correctly excluded" || echo -e "${RED}✗${NC} Ansible config should be excluded"
        ;;
    cloud)
        echo "Checking for CLOUD deployment type..."
        check_file ~/.docker/config.json "Docker config"
        check_file ~/.goproxy "Go proxy"
        check_file ~/.helmrc "Helm config"
        check_file ~/.ssh/config "SSH config"
        ! [ -f ~/.ansible.cfg ] && echo -e "${GREEN}✓${NC} Ansible config correctly excluded" || echo -e "${RED}✗${NC} Ansible config should be excluded"
        ;;
    onprem)
        echo "Checking for ONPREM deployment type..."
        check_file ~/.ssh/config "SSH config"
        check_file ~/.ansible.cfg "Ansible config"
        ! [ -f ~/.docker/config.json ] && echo -e "${GREEN}✓${NC} Docker config correctly excluded" || echo -e "${RED}✗${NC} Docker config should be excluded"
        ! [ -f ~/.helmrc ] && echo -e "${GREEN}✓${NC} Helm config correctly excluded" || echo -e "${RED}✗${NC} Helm config should be excluded"
        ;;
esac

echo ""
echo "=== Proxy Configuration ==="
if [ -n "$PROXY_HOST" ]; then
    echo "Proxy configured: $PROXY_HOST:${PROXY_PORT:-8080}"
    
    # Check Git proxy
    git_proxy=$(git config --get http.proxy 2>/dev/null || true)
    if [ -n "$git_proxy" ]; then
        echo -e "${GREEN}✓${NC} Git proxy configured: $git_proxy"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠${NC} Git proxy not configured"
        ((WARNINGS++))
    fi
    
    # Check environment variables
    source ~/.bashrc 2>/dev/null || true
    check_env_var HTTP_PROXY "HTTP_PROXY"
    check_env_var HTTPS_PROXY "HTTPS_PROXY"
else
    echo "No proxy configured (PROXY_HOST not set)"
fi

echo ""
echo "=== Installed Tools ==="
check_command git "Git"
check_command docker "Docker" || true
check_command go "Go" || true
check_command helm "Helm" || true
check_command gcloud "Google Cloud SDK" || true
check_command ansible "Ansible" || true

echo ""
echo "=== Environment Variables ==="
check_env_var DEPLOYMENT_TYPE "Deployment Type"
check_env_var EDITOR "Editor"

echo ""
echo "=== Summary ==="
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "${RED}Failed:${NC} $FAILED"

if [ $FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}=== Validation SUCCESSFUL ===${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}=== Validation FAILED ===${NC}"
    exit 1
fi
