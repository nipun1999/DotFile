#!/bin/bash

# Ensure Zsh Default Script
# Part of the general dotfile collection
# Ensures zsh is the default shell and configuration is loaded

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

# Function to set zsh as default shell
set_zsh_default() {
    print_status "Setting zsh as default shell..."
    
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
    
    local zsh_path=$(which zsh)
    
    # Check current default shell
    local current_shell=""
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
}

# Function to ensure zsh configuration is loaded
ensure_zsh_config_loaded() {
    print_status "Ensuring zsh configuration is loaded..."
    
    local zshrc_file="$HOME/.zshrc"
    
    # Check if .zshrc exists and has our configuration
    if [ ! -f "$zshrc_file" ]; then
        print_warning ".zshrc not found. Creating basic configuration..."
        touch "$zshrc_file"
    fi
    
    # Check if Oh My Zsh is configured
    if ! grep -q "export ZSH=" "$zshrc_file" 2>/dev/null; then
        print_warning "Oh My Zsh not configured in .zshrc"
        print_status "Run the bootstrap script to configure zsh properly"
        return 1
    fi
    
    # Check if dotfiles aliases are sourced
    local dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    local source_line="source \"$dotfiles_dir/.aliases\""
    
    if ! grep -q "$source_line" "$zshrc_file" 2>/dev/null; then
        print_warning "Dotfiles aliases not sourced in .zshrc"
        print_status "Adding dotfiles aliases source..."
        echo "" >> "$zshrc_file"
        echo "# Source dotfiles aliases" >> "$zshrc_file"
        echo "$source_line" >> "$zshrc_file"
        print_success "Added dotfiles aliases source to .zshrc"
    else
        print_success "Dotfiles aliases already sourced in .zshrc"
    fi
    
    # Source the configuration for current session
    if [ -n "$ZSH_VERSION" ]; then
        print_status "Sourcing .zshrc for current session..."
        source "$zshrc_file"
        print_success "Zsh configuration loaded for current session"
    else
        print_warning "Not in zsh session, configuration will be loaded in new zsh sessions"
    fi
}

# Function to create Cursor terminal configuration
setup_cursor_terminal() {
    print_status "Setting up Cursor terminal configuration..."
    
    # Determine the correct settings directory based on OS
    local cursor_settings_dir=""
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        cursor_settings_dir="$HOME/Library/Application Support/Cursor/User"
    else
        # Linux
        cursor_settings_dir="$HOME/.config/Cursor/User"
    fi
    
    if [ ! -d "$cursor_settings_dir" ]; then
        mkdir -p "$cursor_settings_dir"
    fi
    
    # Create or update settings.json to ensure zsh is used
    local settings_file="$cursor_settings_dir/settings.json"
    
    if [ ! -f "$settings_file" ]; then
        print_status "Creating Cursor settings file..."
        cat > "$settings_file" << 'EOF'
{
    "terminal.integrated.defaultProfile.linux": "zsh",
    "terminal.integrated.profiles.linux": {
        "zsh": {
            "path": "/usr/bin/zsh",
            "args": ["-l"]
        }
    }
}
EOF
        print_success "Created Cursor settings with zsh configuration"
    else
        print_status "Cursor settings file already exists"
        print_status "You may need to manually configure terminal.integrated.defaultProfile.linux to 'zsh'"
    fi
}

# Main function
main() {
    echo -e "${BLUE}🔧 Ensuring Zsh Default Configuration${NC}"
    echo "=========================================="
    
    # Set zsh as default shell
    set_zsh_default
    
    # Ensure zsh configuration is loaded
    ensure_zsh_config_loaded
    
    # Setup Cursor terminal configuration
    setup_cursor_terminal
    
    print_success "Zsh default configuration completed!"
    echo ""
    print_status "Next steps:"
    print_status "  1. Restart Cursor to apply terminal settings"
    print_status "  2. Open a new terminal in Cursor"
    print_status "  3. Or log out and log back in to use zsh as default shell"
    echo ""
    print_status "To test the configuration:"
    print_status "  - Open a new terminal in Cursor"
    print_status "  - Run: echo $SHELL (should show zsh path)"
    print_status "  - Run: echo $ZSH_VERSION (should show zsh version)"
    print_status "  - Test aliases: g status (should work if git is available)"
} 