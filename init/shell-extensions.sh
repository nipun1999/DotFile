#!/bin/bash

# Zsh Extensions Installer
# Part of the general dotfile collection
# Installs and configures important zsh extensions for productivity

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

# Function to install package manager packages
install_packages() {
    local packages=("$@")
    
    if command_exists brew; then
        print_status "Installing packages with Homebrew..."
        for package in "${packages[@]}"; do
            if ! brew list "$package" >/dev/null 2>&1; then
                print_status "Installing $package..."
                brew install "$package"
                print_success "Installed $package"
            else
                print_success "$package already installed"
            fi
        done
    elif command_exists apt-get; then
        print_status "Installing packages with apt-get..."
        sudo apt-get update
        for package in "${packages[@]}"; do
            print_status "Installing $package..."
            sudo apt-get install -y "$package"
        done
    elif command_exists yum; then
        print_status "Installing packages with yum..."
        for package in "${packages[@]}"; do
            print_status "Installing $package..."
            sudo yum install -y "$package"
        done
    else
        print_warning "No supported package manager found (brew, apt-get, yum)"
        return 1
    fi
}

# Function to setup zsh with Oh My Zsh and plugins
setup_zsh_extensions() {
    local home_dir="$1"
    
    print_status "Setting up basic Zsh extensions..."
    
    # Install Oh My Zsh if not already installed
    if [ ! -d "$home_dir/.oh-my-zsh" ]; then
        print_status "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed"
    else
        print_success "Oh My Zsh already installed"
    fi
    
    # Install zsh-autosuggestions
    if [ ! -d "$home_dir/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        print_status "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$home_dir/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
        print_success "zsh-autosuggestions installed"
    else
        print_success "zsh-autosuggestions already installed"
    fi
    
    # Install zsh-syntax-highlighting
    if [ ! -d "$home_dir/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
        print_status "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$home_dir/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
        print_success "zsh-syntax-highlighting installed"
    else
        print_success "zsh-syntax-highlighting already installed"
    fi
    
    # Install zsh-completions
    if [ ! -d "$home_dir/.oh-my-zsh/custom/plugins/zsh-completions" ]; then
        print_status "Installing zsh-completions..."
        git clone https://github.com/zsh-users/zsh-completions "$home_dir/.oh-my-zsh/custom/plugins/zsh-completions"
        print_success "zsh-completions installed"
    else
        print_success "zsh-completions already installed"
    fi
}

# Function to configure zsh config file
configure_zsh_config() {
    local zshrc_file="$1"
    local home_dir="$2"
    local dotfiles_dir="$3"
    
    print_status "Configuring basic $zshrc_file..."
    
    # Create config file if it doesn't exist
    if [ ! -f "$zshrc_file" ]; then
        print_status "Creating $zshrc_file"
        touch "$zshrc_file"
    fi
    
    # Backup existing config
    if [ -f "$zshrc_file" ] && [ -s "$zshrc_file" ]; then
        cp "$zshrc_file" "$zshrc_file.backup.$(date +%Y%m%d-%H%M%S)"
        print_status "Backup created: $zshrc_file.backup.$(date +%Y%m%d-%H%M%S)"
    fi
    
    # Add basic Oh My Zsh configuration
    if ! grep -q "export ZSH=" "$zshrc_file" 2>/dev/null; then
        cat >> "$zshrc_file" << 'EOF'

# Basic Oh My Zsh Configuration
export ZSH="$HOME/.oh-my-zsh"

# No theme (basic)
ZSH_THEME=""

# Essential plugins only
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Basic completions
autoload -U compinit && compinit

# Basic prompt if no theme
if [ -z "$ZSH_THEME" ]; then
    PROMPT='%n@%m %~ %# '
fi

EOF
        print_success "Basic Oh My Zsh configuration added to $zshrc_file"
    else
        print_success "Oh My Zsh already configured in $zshrc_file"
    fi
    
    # Add dotfiles aliases source
    local source_line="source \"$dotfiles_dir/.aliases\""
    if ! grep -q "$source_line" "$zshrc_file" 2>/dev/null; then
        echo "" >> "$zshrc_file"
        echo "# Source dotfiles aliases" >> "$zshrc_file"
        echo "$source_line" >> "$zshrc_file"
        print_success "Aliases source added to $zshrc_file"
    else
        print_success "Aliases already configured in $zshrc_file"
    fi
}

# Main installation function
install_shell_extensions() {
    local remote_connection="$1"
    
    echo -e "${BLUE}🔧 Installing Zsh Extensions${NC}"
    echo "=================================="
    
    # Get home directory
    local home_dir="$HOME"
    local dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    local zshrc_file="$home_dir/.zshrc"
    
    print_status "Home directory: $home_dir"
    print_status "Dotfiles directory: $dotfiles_dir"
    print_status "Zshrc file: $zshrc_file"
    
    # Install essential packages
    print_status "Installing essential packages..."
    local packages=(
        "git"
        "curl"
        "wget"
        "tree"
        "htop"
        "jq"
    )
    
    install_packages "${packages[@]}"
    
    # Setup zsh extensions
    setup_zsh_extensions "$home_dir"
    
    # Configure zsh config file
    configure_zsh_config "$zshrc_file" "$home_dir" "$dotfiles_dir"
    
    print_success "Basic zsh extensions installation completed!"
    echo ""
    print_status "Installed basic zsh extensions:"
    echo "  - Oh My Zsh (basic setup)"
    echo "  - zsh-autosuggestions"
    echo "  - zsh-syntax-highlighting"
    echo "  - zsh-completions"
    echo "  - Essential packages (git, curl, wget, tree, htop, jq)"
    echo ""
    print_status "Please restart your terminal or run 'source $zshrc_file' to see the changes."
} 