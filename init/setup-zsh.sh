#!/bin/bash

# Zsh Setup Script
# Part of the general dotfile collection
# Handles complete zsh setup: aliases, plugins, and basic configuration

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

# Function to install zsh if needed
install_zsh() {
    print_status "Ensuring zsh is installed..."
    
    # Debug: Check multiple ways zsh might be available
    local zsh_path=""
    if command_exists zsh; then
        zsh_path=$(which zsh)
        print_status "Found zsh at: $zsh_path"
    elif [ -f "/usr/bin/zsh" ]; then
        zsh_path="/usr/bin/zsh"
        print_status "Found zsh at: $zsh_path"
    elif [ -f "/bin/zsh" ]; then
        zsh_path="/bin/zsh"
        print_status "Found zsh at: $zsh_path"
    fi
    
    if [ -n "$zsh_path" ]; then
        print_success "Zsh is already installed at: $zsh_path"
        return 0
    fi
    
    print_warning "Zsh is not installed. Installing zsh..."
    
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
        return 1
    fi
    
    # Check again after installation
    if command_exists zsh; then
        print_success "Zsh installed successfully at: $(which zsh)"
    else
        print_error "Failed to install zsh"
        return 1
    fi
}

# Function to set zsh as default shell
set_zsh_default() {
    print_status "Setting zsh as default shell..."
    
    # Find zsh path
    local zsh_path=""
    if command_exists zsh; then
        zsh_path=$(which zsh)
    elif [ -f "/usr/bin/zsh" ]; then
        zsh_path="/usr/bin/zsh"
    elif [ -f "/bin/zsh" ]; then
        zsh_path="/bin/zsh"
    fi
    
    if [ -z "$zsh_path" ]; then
        print_error "Cannot find zsh installation"
        return 1
    fi
    
    print_status "Zsh path: $zsh_path"
    
    # Get current default shell
    local current_shell=""
    if command_exists dscl; then
        # macOS
        current_shell=$(dscl . -read /Users/$USER UserShell | awk '{print $2}')
    else
        # Linux
        current_shell=$(getent passwd $USER | cut -d: -f7)
    fi
    
    print_status "Current default shell: $current_shell"
    
    if [ "$current_shell" != "$zsh_path" ]; then
        print_warning "Current default shell is not zsh: $current_shell"
        print_status "Setting zsh as default shell..."
        
        sudo chsh -s "$zsh_path" "$USER"
        
        if [ $? -eq 0 ]; then
            print_success "Zsh set as default shell: $zsh_path"
        else
            print_warning "Failed to set zsh as default shell, continuing..."
        fi
    else
        print_success "Zsh is already the default shell"
    fi
}

# Function to install Oh My Zsh and plugins
install_oh_my_zsh() {
    local home_dir="$1"
    
    print_status "Installing Oh My Zsh and plugins..."
    
    local omz_installed=0
    local omz_skipped=0
    
    # Install Oh My Zsh
    if [ ! -d "$home_dir/.oh-my-zsh" ]; then
        print_status "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed"
        ((omz_installed++))
    else
        print_success "Oh My Zsh already installed"
        ((omz_skipped++))
    fi
    
    # Install essential plugins
    local plugins=(
        "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions.git"
        "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting.git"
        "zsh-completions:https://github.com/zsh-users/zsh-completions.git"
    )
    
    # Ensure custom plugins directory exists
    local custom_plugins_dir="$home_dir/.oh-my-zsh/custom/plugins"
    mkdir -p "$custom_plugins_dir"
    
    for plugin in "${plugins[@]}"; do
        local plugin_name=$(echo "$plugin" | sed 's/:.*//')
        local plugin_url=$(echo "$plugin" | sed 's/^[^:]*://')
        
        # Different paths for different plugins
        local plugin_dir=""
        case "$plugin_name" in
            "zsh-autosuggestions")
                plugin_dir="$home_dir/.oh-my-zsh/custom/plugins/$plugin_name"
                ;;
            "zsh-syntax-highlighting")
                plugin_dir="$home_dir/.oh-my-zsh/custom/plugins/$plugin_name"
                ;;
            "zsh-completions")
                plugin_dir="$home_dir/.oh-my-zsh/custom/plugins/$plugin_name"
                ;;
        esac
        
        if [ ! -d "$plugin_dir" ]; then
            print_status "Installing $plugin_name..."
            print_status "Cloning from: $plugin_url"
            print_status "Installing to: $plugin_dir"
            if git clone "$plugin_url" "$plugin_dir"; then
                print_success "$plugin_name installed"
                ((omz_installed++))
            else
                print_warning "Failed to install $plugin_name, continuing..."
                print_status "Checking if directory was created anyway..."
                if [ -d "$plugin_dir" ]; then
                    print_success "$plugin_name directory exists, plugin may be available"
                    ((omz_installed++))
                else
                    print_warning "$plugin_name directory not found"
                fi
            fi
        else
            print_success "$plugin_name already installed"
            ((omz_skipped++))
        fi
    done
    
    # Return Oh My Zsh installation status
    if [ $omz_installed -gt 0 ]; then
        echo "omz_installed:$omz_installed"
    fi
    if [ $omz_skipped -gt 0 ]; then
        echo "omz_skipped:$omz_skipped"
    fi
}

# Function to create comprehensive .zshrc
create_zshrc() {
    local home_dir="$1"
    local dotfiles_dir="$2"
    local zshrc_file="$home_dir/.zshrc"
    
    print_status "Checking .zshrc configuration..."
    
    # Check if .zshrc already exists and has our configuration
    if [ -f "$zshrc_file" ]; then
        if grep -q "Generated by dotfiles setup script" "$zshrc_file" && \
           grep -q "zsh-autosuggestions" "$zshrc_file" && \
           grep -q "zsh-syntax-highlighting" "$zshrc_file"; then
            print_success ".zshrc already configured correctly"
            return 0
        else
            print_status "Backing up existing .zshrc..."
            cp "$zshrc_file" "$zshrc_file.backup.$(date +%Y%m%d-%H%M%S)"
            print_status "Backup created: $zshrc_file.backup.$(date +%Y%m%d-%H%M%S)"
        fi
    fi
    
    print_status "Creating comprehensive .zshrc..."
    
    # Backup existing .zshrc
    if [ -f "$zshrc_file" ]; then
        cp "$zshrc_file" "$zshrc_file.backup.$(date +%Y%m%d-%H%M%S)"
        print_status "Backup created: $zshrc_file.backup.$(date +%Y%m%d-%H%M%S)"
    fi
    
    # Create comprehensive .zshrc
    cat > "$zshrc_file" << 'EOF'
# =============================================================================
# Zsh Configuration
# Generated by dotfiles setup script
# =============================================================================

# =============================================================================
# Oh My Zsh Configuration
# =============================================================================

export ZSH="$HOME/.oh-my-zsh"

# No theme (basic and clean)
ZSH_THEME=""

# Essential plugins for productivity
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# =============================================================================
# Environment Variables
# =============================================================================

# Add custom paths if they exist
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi

# =============================================================================
# History Configuration
# =============================================================================

HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# =============================================================================
# Completions
# =============================================================================

autoload -U compinit && compinit

# =============================================================================
# Source Dotfiles Aliases
# =============================================================================

EOF

    # Add the dotfiles aliases source line
    echo "# Source dotfiles aliases" >> "$zshrc_file"
    echo "source \"$dotfiles_dir/.aliases\"" >> "$zshrc_file"
    
    # Add final section
    cat >> "$zshrc_file" << 'EOF'

# =============================================================================
# Basic Prompt (if no theme)
# =============================================================================

if [ -z "$ZSH_THEME" ]; then
    PROMPT='%n@%m %~ %# '
fi

# =============================================================================
# Extensible Configuration Area
# =============================================================================

# Add your custom configurations below this line
# This area is preserved during updates

EOF

    print_success "Comprehensive .zshrc created at $zshrc_file"
}

# Function to install essential packages
install_packages() {
    print_status "Installing essential packages..."
    
    local packages=("curl" "wget" "tree" "htop" "jq")
    local installed_count=0
    local skipped_count=0
    
    if command_exists apt-get; then
        # Ubuntu/Debian
        for package in "${packages[@]}"; do
            if dpkg -l | grep -q "^ii  $package "; then
                print_success "$package already installed"
                ((skipped_count++))
            else
                print_status "Installing $package..."
                sudo apt-get install -y "$package"
                ((installed_count++))
            fi
        done
    elif command_exists yum; then
        # CentOS/RHEL
        for package in "${packages[@]}"; do
            if rpm -q "$package" >/dev/null 2>&1; then
                print_success "$package already installed"
                ((skipped_count++))
            else
                print_status "Installing $package..."
                sudo yum install -y "$package"
                ((installed_count++))
            fi
        done
    elif command_exists brew; then
        # macOS
        for package in "${packages[@]}"; do
            if brew list "$package" >/dev/null 2>&1; then
                print_success "$package already installed"
                ((skipped_count++))
            else
                print_status "Installing $package..."
                brew install "$package"
                ((installed_count++))
            fi
        done
    else
        print_warning "No supported package manager found, skipping package installation"
    fi
    
    # Return package installation status
    if [ $installed_count -gt 0 ]; then
        echo "packages_installed:$installed_count"
    fi
    if [ $skipped_count -gt 0 ]; then
        echo "packages_skipped:$skipped_count"
    fi
}

# Main setup function
setup_zsh() {
    local remote_connection="$1"
    
    echo -e "${BLUE}🔧 Setting up Zsh Configuration${NC}"
    echo "=================================="
    
    local home_dir="$HOME"
    local dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    
    print_status "Home directory: $home_dir"
    print_status "Dotfiles directory: $dotfiles_dir"
    
    # Track what was installed vs what was already there
    local installed_components=()
    local skipped_components=()
    
    # Install zsh if needed
    if ! command_exists zsh && [ ! -f "/usr/bin/zsh" ] && [ ! -f "/bin/zsh" ]; then
        install_zsh
        installed_components+=("zsh")
    else
        print_success "Zsh is already installed"
        skipped_components+=("zsh")
    fi
    
    # Set zsh as default shell if needed
    local zsh_path=""
    if command_exists zsh; then
        zsh_path=$(which zsh)
    elif [ -f "/usr/bin/zsh" ]; then
        zsh_path="/usr/bin/zsh"
    elif [ -f "/bin/zsh" ]; then
        zsh_path="/bin/zsh"
    fi
    
    local current_shell=""
    if command_exists dscl; then
        current_shell=$(dscl . -read /Users/$USER UserShell | awk '{print $2}')
    else
        current_shell=$(getent passwd $USER | cut -d: -f7)
    fi
    
    if [ "$current_shell" != "$zsh_path" ]; then
        set_zsh_default
        installed_components+=("default shell")
    else
        print_success "Zsh is already the default shell"
        skipped_components+=("default shell")
    fi
    
    # Install packages
    local package_results=$(install_packages)
    local packages_installed=$(echo "$package_results" | grep "packages_installed:" | cut -d: -f2)
    local packages_skipped=$(echo "$package_results" | grep "packages_skipped:" | cut -d: -f2)
    
    if [ -n "$packages_installed" ] && [ "$packages_installed" -gt 0 ]; then
        installed_components+=("essential packages ($packages_installed new)")
    fi
    if [ -n "$packages_skipped" ] && [ "$packages_skipped" -gt 0 ]; then
        skipped_components+=("essential packages ($packages_skipped existing)")
    fi
    
    # Install Oh My Zsh and plugins
    local omz_results=$(install_oh_my_zsh "$home_dir")
    local omz_installed=$(echo "$omz_results" | grep "omz_installed:" | cut -d: -f2)
    local omz_skipped=$(echo "$omz_results" | grep "omz_skipped:" | cut -d: -f2)
    
    if [ -n "$omz_installed" ] && [ "$omz_installed" -gt 0 ]; then
        installed_components+=("Oh My Zsh and plugins ($omz_installed new)")
    fi
    if [ -n "$omz_skipped" ] && [ "$omz_skipped" -gt 0 ]; then
        skipped_components+=("Oh My Zsh and plugins ($omz_skipped existing)")
    fi
    
    # Create .zshrc
    if create_zshrc "$home_dir" "$dotfiles_dir"; then
        installed_components+=("zshrc configuration")
    else
        skipped_components+=("zshrc configuration")
    fi
    
    print_success "Zsh setup completed successfully!"
    echo ""
    
    if [ ${#installed_components[@]} -gt 0 ]; then
        print_status "✅ Installed/Updated:"
        for component in "${installed_components[@]}"; do
            print_status "  - $component"
        done
    fi
    
    if [ ${#skipped_components[@]} -gt 0 ]; then
        print_status "⏭️  Skipped (already exists):"
        for component in "${skipped_components[@]}"; do
            print_status "  - $component"
        done
    fi
    
    echo ""
    print_status "Your zsh configuration includes:"
    print_status "  ✅ All your aliases loaded"
    print_status "  ✅ Oh My Zsh framework"
    print_status "  ✅ zsh-autosuggestions (fish-like suggestions)"
    print_status "  ✅ zsh-syntax-highlighting (command highlighting)"
    print_status "  ✅ zsh-completions (enhanced completions)"
    print_status "  ✅ Git plugin"
    print_status "  ✅ Essential packages (git, curl, wget, tree, htop, jq)"
    print_status "  ✅ Extensible configuration area for future additions"
    echo ""
    print_status "To apply the configuration:"
    print_status "  - Restart your terminal"
    print_status "  - Or run: source ~/.zshrc"
    echo ""
    print_status "You should now see:"
    print_status "  - Command suggestions as you type"
    print_status "  - Syntax highlighting (valid/invalid commands)"
    print_status "  - Enhanced tab completion"
    print_status "  - All your aliases working"
} 