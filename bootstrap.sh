#!/bin/bash

# Bootstrap script for general dotfiles
# Inspired by https://github.com/mathiasbynens/dotfiles
# Focused on aliases, shell extensions, and cursor extensions
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

# Function to setup aliases in shell config
setup_aliases() {
    local dotfiles_dir="$1"
    local aliases_file="$dotfiles_dir/.aliases"
    
    if [ ! -f "$aliases_file" ]; then
        print_warning "Aliases file not found at $aliases_file"
        return 1
    fi
    
    print_status "Setting up aliases in shell configuration..."
    
    # Determine shell and config file
    local shell_config=""
    local shell_name=""
    
    if [ -n "$ZSH_VERSION" ]; then
        shell_name="zsh"
        shell_config="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        shell_name="bash"
        shell_config="$HOME/.bashrc"
    else
        # Try to detect shell
        local current_shell=$(basename "$SHELL")
        case "$current_shell" in
            "zsh")
                shell_name="zsh"
                shell_config="$HOME/.zshrc"
                ;;
            "bash")
                shell_name="bash"
                shell_config="$HOME/.bashrc"
                ;;
            *)
                print_warning "Unknown shell: $current_shell, defaulting to bash"
                shell_name="bash"
                shell_config="$HOME/.bashrc"
                ;;
        esac
    fi
    
    print_status "Detected shell: $shell_name"
    print_status "Config file: $shell_config"
    
    # Create config file if it doesn't exist
    if [ ! -f "$shell_config" ]; then
        print_status "Creating $shell_config"
        touch "$shell_config"
    fi
    
    # Check if aliases are already sourced in the config
    local source_line="source \"$aliases_file\""
    if grep -q "$source_line" "$shell_config" 2>/dev/null; then
        print_success "Aliases already configured in $shell_config"
    else
        # Add source line to config file
        echo "" >> "$shell_config"
        echo "# Source dotfiles aliases" >> "$shell_config"
        echo "$source_line" >> "$shell_config"
        print_success "Added aliases source to $shell_config"
    fi
    
    # Also source aliases for current session
    print_status "Sourcing aliases for current session..."
    source "$aliases_file"
    print_success "Aliases loaded for current session"
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

# Setup aliases
setup_aliases "$DOTFILES_DIR"

# Install shell extensions
if [ -f "$DOTFILES_DIR/init/shell-extensions.sh" ]; then
    print_status "Installing shell extensions..."
    source "$DOTFILES_DIR/init/shell-extensions.sh"
    install_shell_extensions "$1"
else
    print_warning "Shell extensions script not found"
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
print_status "Aliases have been added to your shell configuration."
print_status "Shell extensions have been installed and configured."
print_status "You may need to restart your terminal or run 'source ~/.bashrc' (or ~/.zshrc) for changes to take effect."
print_status "Alternatively, you can start a new shell session to see all the improvements." 