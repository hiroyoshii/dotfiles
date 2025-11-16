#!/bin/bash
# Quick setup script for dotfiles deployment

set -e

echo "=== Dotfiles Quick Setup ==="
echo ""

# Prompt for deployment type
echo "Select deployment type:"
echo "  1) all (default - all features)"
echo "  2) edge (git, docker, golang, ssh)"
echo "  3) cloud (git, docker, golang, helm, gcloud, ssh)"
echo "  4) onprem (git, ssh, ansible)"
read -p "Enter choice [1-4] (default: 1): " choice

case $choice in
  2) export DEPLOYMENT_TYPE=edge ;;
  3) export DEPLOYMENT_TYPE=cloud ;;
  4) export DEPLOYMENT_TYPE=onprem ;;
  *) export DEPLOYMENT_TYPE=all ;;
esac

echo "Deployment type: $DEPLOYMENT_TYPE"
echo ""

# Prompt for proxy settings
read -p "Are you behind a proxy? [y/N]: " use_proxy
if [[ $use_proxy =~ ^[Yy]$ ]]; then
  read -p "Proxy host: " proxy_host
  read -p "Proxy port [8080]: " proxy_port
  proxy_port=${proxy_port:-8080}
  read -p "No proxy domains [localhost,127.0.0.1,.local]: " no_proxy
  no_proxy=${no_proxy:-localhost,127.0.0.1,.local}
  
  export PROXY_HOST=$proxy_host
  export PROXY_PORT=$proxy_port
  export NO_PROXY=$no_proxy
else
  export PROXY_HOST=
fi

echo ""

# Prompt for Git settings
read -p "Git user name: " git_name
read -p "Git user email: " git_email

export GIT_USER_NAME="$git_name"
export GIT_USER_EMAIL="$git_email"

echo ""
echo "=== Configuration Summary ==="
echo "Deployment type: $DEPLOYMENT_TYPE"
if [ -n "$PROXY_HOST" ]; then
  echo "Proxy: $PROXY_HOST:$PROXY_PORT"
  echo "No proxy: $NO_PROXY"
else
  echo "Proxy: Not configured"
fi
echo "Git user: $GIT_USER_NAME <$GIT_USER_EMAIL>"
echo ""

read -p "Proceed with installation? [Y/n]: " confirm
if [[ ! $confirm =~ ^[Nn]$ ]]; then
  # Install chezmoi if not already installed
  if ! command -v chezmoi &> /dev/null; then
    echo "Installing chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)"
  fi
  
  # Initialize and apply dotfiles
  echo "Applying dotfiles..."
  chezmoi init --apply https://github.com/hiroyoshii/dotfiles.git
  
  echo ""
  echo "=== Setup Complete! ==="
  echo "Please run 'source ~/.bashrc' to activate the configuration"
else
  echo "Installation cancelled."
fi
