#!/bin/bash

# Bootstrap script for general dotfiles
# Inspired by https://github.com/mathiasbynens/dotfiles
# Focused on aliases and cursor extensions only
# Supports both local and remote installations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [remote-connection-string]"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Bootstrap locally"
    echo "  $0 ssh-remote+user@hostname          # Bootstrap on SSH remote"
    echo "  $0 dev-container+container-name      # Bootstrap in dev container"
    echo "  $0 wsl+distro-name                   # Bootstrap in WSL"
    echo ""
    echo "The remote connection string will be passed to the cursor extensions installer."
}

# Main script logic
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_usage
    exit 0
fi

echo -e "${BLUE}🚀 General Dotfiles Bootstrap${NC}"
echo "=================================="

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_status "Dotfiles directory: $DOTFILES_DIR"

# Source aliases
if [ -f "$DOTFILES_DIR/.aliases" ]; then
    print_status "Sourcing .aliases"
    source "$DOTFILES_DIR/.aliases"
    print_success "Aliases loaded"
else
    print_warning "Aliases file not found"
fi

# Install Cursor extensions if cursor CLI is available
if command_exists cursor; then
    print_status "Installing Cursor extensions..."
    if [ -f "$DOTFILES_DIR/init/cursor-extensions.sh" ]; then
        if [ -n "$1" ]; then
            print_status "Using remote connection: $1"
            source "$DOTFILES_DIR/init/cursor-extensions.sh" "$1"
        else
            source "$DOTFILES_DIR/init/cursor-extensions.sh"
        fi
    else
        print_warning "Cursor extensions script not found"
    fi
else
    print_warning "Cursor CLI not found, skipping extensions installation"
fi

print_success "Bootstrap complete!"
echo ""
print_status "You may need to restart your terminal or run 'source ~/.bashrc' (or ~/.zshrc) for changes to take effect." 