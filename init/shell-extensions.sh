#!/bin/bash

# Shell Extensions Installer
# Part of the general dotfile collection
# Installs and configures important shell extensions for productivity

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

# Function to setup zsh with Oh My Zsh
setup_zsh_extensions() {
    local home_dir="$1"
    
    print_status "Setting up Zsh extensions..."
    
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

# Function to setup bash extensions
setup_bash_extensions() {
    local home_dir="$1"
    
    print_status "Setting up Bash extensions..."
    
    # Install bash-completion
    if command_exists brew; then
        if ! brew list bash-completion >/dev/null 2>&1; then
            print_status "Installing bash-completion..."
            brew install bash-completion
            print_success "bash-completion installed"
        else
            print_success "bash-completion already installed"
        fi
    fi
    
    # Install fzf (fuzzy finder)
    if [ ! -d "$home_dir/.fzf" ]; then
        print_status "Installing fzf..."
        git clone --depth 1 https://github.com/junegunn/fzf.git "$home_dir/.fzf"
        "$home_dir/.fzf/install" --all
        print_success "fzf installed"
    else
        print_success "fzf already installed"
    fi
}

# Function to configure shell config file
configure_shell_config() {
    local shell_config="$1"
    local shell_type="$2"
    local home_dir="$3"
    local dotfiles_dir="$4"
    
    print_status "Configuring $shell_config..."
    
    # Create config file if it doesn't exist
    if [ ! -f "$shell_config" ]; then
        print_status "Creating $shell_config"
        touch "$shell_config"
    fi
    
    # Backup existing config
    if [ -f "$shell_config" ] && [ -s "$shell_config" ]; then
        cp "$shell_config" "$shell_config.backup.$(date +%Y%m%d-%H%M%S)"
        print_status "Backup created: $shell_config.backup.$(date +%Y%m%d-%H%M%S)"
    fi
    
    # Add Oh My Zsh configuration for zsh
    if [ "$shell_type" = "zsh" ]; then
        # Check if Oh My Zsh is already configured
        if ! grep -q "export ZSH=" "$shell_config" 2>/dev/null; then
            cat >> "$shell_config" << 'EOF'

# Oh My Zsh Configuration
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
    git
    docker
    python
    node
    npm
    yarn
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Additional completions
autoload -U compinit && compinit

EOF
            print_success "Oh My Zsh configuration added to $shell_config"
        else
            print_success "Oh My Zsh already configured in $shell_config"
        fi
    fi
    
    # Add bash-completion for bash
    if [ "$shell_type" = "bash" ]; then
        if ! grep -q "bash_completion" "$shell_config" 2>/dev/null; then
            cat >> "$shell_config" << 'EOF'

# Bash completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

EOF
            print_success "Bash completion configuration added to $shell_config"
        else
            print_success "Bash completion already configured in $shell_config"
        fi
    fi
    
    # Add fzf configuration
    if ! grep -q "fzf" "$shell_config" 2>/dev/null; then
        cat >> "$shell_config" << 'EOF'

# FZF configuration
if [ -f ~/.fzf.bash ]; then
    source ~/.fzf.bash
elif [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
fi

EOF
        print_success "FZF configuration added to $shell_config"
    else
        print_success "FZF already configured in $shell_config"
    fi
    
    # Add dotfiles aliases source
    local source_line="source \"$dotfiles_dir/.aliases\""
    if ! grep -q "$source_line" "$shell_config" 2>/dev/null; then
        echo "" >> "$shell_config"
        echo "# Source dotfiles aliases" >> "$shell_config"
        echo "$source_line" >> "$shell_config"
        print_success "Aliases source added to $shell_config"
    else
        print_success "Aliases already configured in $shell_config"
    fi
}

# Main installation function
install_shell_extensions() {
    local remote_connection="$1"
    
    echo -e "${BLUE}🔧 Installing Shell Extensions${NC}"
    echo "=================================="
    
    # Get home directory
    local home_dir="$HOME"
    local dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    
    print_status "Home directory: $home_dir"
    print_status "Dotfiles directory: $dotfiles_dir"
    
    # Install essential packages
    print_status "Installing essential packages..."
    local packages=(
        "git"
        "curl"
        "wget"
        "tree"
        "htop"
        "jq"
        "fzf"
    )
    
    install_packages "${packages[@]}"
    
    # Determine shell and setup accordingly
    local shell_config=""
    local shell_type=""
    
    if [ -n "$ZSH_VERSION" ]; then
        shell_type="zsh"
        shell_config="$home_dir/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        shell_type="bash"
        shell_config="$home_dir/.bashrc"
    else
        # Try to detect shell
        local current_shell=$(basename "$SHELL")
        case "$current_shell" in
            "zsh")
                shell_type="zsh"
                shell_config="$home_dir/.zshrc"
                ;;
            "bash")
                shell_type="bash"
                shell_config="$home_dir/.bashrc"
                ;;
            *)
                print_warning "Unknown shell: $current_shell, defaulting to bash"
                shell_type="bash"
                shell_config="$home_dir/.bashrc"
                ;;
        esac
    fi
    
    print_status "Detected shell: $shell_type"
    print_status "Config file: $shell_config"
    
    # Setup shell-specific extensions
    if [ "$shell_type" = "zsh" ]; then
        setup_zsh_extensions "$home_dir"
    else
        setup_bash_extensions "$home_dir"
    fi
    
    # Configure shell config file
    configure_shell_config "$shell_config" "$shell_type" "$home_dir" "$dotfiles_dir"
    
    print_success "Shell extensions installation completed!"
    echo ""
    print_status "Installed extensions:"
    echo "  - Oh My Zsh (for zsh)"
    echo "  - zsh-autosuggestions"
    echo "  - zsh-syntax-highlighting"
    echo "  - zsh-completions"
    echo "  - bash-completion (for bash)"
    echo "  - fzf (fuzzy finder)"
    echo "  - Essential packages (git, curl, wget, tree, htop, jq)"
    echo ""
    print_status "Please restart your terminal or run 'source $shell_config' to see the changes."
} 