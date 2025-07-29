#!/bin/bash

# Bootstrap script for general dotfiles
# Inspired by https://github.com/mathiasbynens/dotfiles
# Focused on zsh configuration, aliases, shell extensions, and cursor extensions
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

# Function to setup zsh configuration
setup_zsh_config() {
    local dotfiles_dir="$1"
    local aliases_file="$dotfiles_dir/.aliases"
    local zshrc_file="$HOME/.zshrc"
    
    if [ ! -f "$aliases_file" ]; then
        print_warning "Aliases file not found at $aliases_file"
        return 1
    fi
    
    print_status "Setting up Zsh configuration..."
    print_status "Zshrc file: $zshrc_file"
    
    # Create .zshrc if it doesn't exist
    if [ ! -f "$zshrc_file" ]; then
        print_status "Creating $zshrc_file"
        touch "$zshrc_file"
    fi
    
    # Check if dotfiles are already sourced in the config
    local source_line="source \"$aliases_file\""
    if grep -q "$source_line" "$zshrc_file" 2>/dev/null; then
        print_success "Dotfiles aliases already configured in $zshrc_file"
    else
        # Add source line to config file
        echo "" >> "$zshrc_file"
        echo "# Source dotfiles aliases" >> "$zshrc_file"
        echo "$source_line" >> "$zshrc_file"
        print_success "Added dotfiles aliases source to $zshrc_file"
    fi
    
    # Also source aliases for current session
    print_status "Sourcing aliases for current session..."
    source "$aliases_file"
    print_success "Aliases loaded for current session"
}

# Function to ensure zsh is the default shell
ensure_zsh_default() {
    print_status "Ensuring zsh is the default shell..."
    
    # Check if zsh is available
    if ! command_exists zsh; then
        print_warning "Zsh is not installed. Installing zsh..."
        
        # Install zsh based on the system
        if command_exists apt-get; then
            # Ubuntu/Debian
            print_status "Installing zsh via apt-get..."
            sudo apt-get update
            sudo apt-get install -y zsh
        elif command_exists yum; then
            # CentOS/RHEL
            print_status "Installing zsh via yum..."
            sudo yum install -y zsh
        elif command_exists brew; then
            # macOS
            print_status "Installing zsh via Homebrew..."
            brew install zsh
        else
            print_error "No supported package manager found. Please install zsh manually."
            print_status "On Ubuntu: sudo apt-get install zsh"
            print_status "On CentOS: sudo yum install zsh"
            print_status "On macOS: brew install zsh"
            return 1
        fi
        
        if ! command_exists zsh; then
            print_error "Failed to install zsh"
            return 1
        else
            print_success "Zsh installed successfully"
        fi
    fi
    
    # Check current default shell
    local current_shell=""
    local zsh_path=$(which zsh)
    
    if command_exists dscl; then
        # macOS
        current_shell=$(dscl . -read /Users/$USER UserShell | awk '{print $2}')
    else
        # Linux
        current_shell=$(getent passwd $USER | cut -d: -f7)
    fi
    
    if [ "$current_shell" != "$zsh_path" ]; then
        print_warning "Current default shell is not zsh: $current_shell"
        print_status "Setting zsh as default shell..."
        
        # Set zsh as default shell
        sudo chsh -s "$zsh_path" "$USER"
        
        if [ $? -eq 0 ]; then
            print_success "Zsh set as default shell: $zsh_path"
            print_warning "You may need to log out and log back in for changes to take effect"
        else
            print_error "Failed to set zsh as default shell"
            print_warning "Continuing with current shell..."
        fi
    else
        print_success "Zsh is already the default shell: $current_shell"
    fi
    
    # Check if current session is using zsh
    if [ "$SHELL" != "$zsh_path" ] && [ "$SHELL" != "/bin/zsh" ] && [ "$SHELL" != "/usr/bin/zsh" ]; then
        print_warning "Current session is not using zsh: $SHELL"
        print_status "Starting a new zsh session..."
        exec zsh
    else
        print_success "Current session is using zsh: $SHELL"
    fi
}

# Main script logic
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_usage
    exit 0
fi

echo -e "${BLUE}🚀 Zsh-Focused Dotfiles Bootstrap${NC}"
echo "======================================"

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_status "Dotfiles directory: $DOTFILES_DIR"

# Ensure zsh is the default shell
ensure_zsh_default

# Setup zsh configuration
setup_zsh_config "$DOTFILES_DIR"

# Install zsh extensions
if [ -f "$DOTFILES_DIR/init/shell-extensions.sh" ]; then
    print_status "Installing zsh extensions..."
    source "$DOTFILES_DIR/init/shell-extensions.sh"
    install_shell_extensions "$1"
else
    print_warning "Shell extensions script not found"
fi

# Ensure zsh is default and configuration is loaded
if [ -f "$DOTFILES_DIR/init/ensure-zsh-default.sh" ]; then
    print_status "Ensuring zsh is default and configuration is loaded..."
    source "$DOTFILES_DIR/init/ensure-zsh-default.sh"
    main
else
    print_warning "Ensure zsh default script not found"
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

print_success "Zsh-focused bootstrap complete!"
echo ""
print_status "Zsh configuration has been set up with:"
print_status "  - Dotfiles aliases integrated"
print_status "  - Oh My Zsh with plugins"
print_status "  - zsh-autosuggestions"
print_status "  - zsh-syntax-highlighting"
print_status "  - zsh-completions"
print_status "  - Essential packages"
print_status ""
print_status "To load the configuration in Cursor's terminal:"
print_status "  1. Open a new terminal in Cursor"
print_status "  2. Or run: source ~/.zshrc"
print_status "  3. Or restart Cursor completely"
print_status ""
print_status "To change your default shell to zsh (recommended):"
print_status "  chsh -s $(which zsh)" 