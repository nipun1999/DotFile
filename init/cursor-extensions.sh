#!/bin/bash

# Cursor Extensions Installer
# Part of the general dotfile collection
# Inspired by https://github.com/mathiasbynens/dotfiles
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
    echo "  $0                                    # Install extensions locally"
    echo "  $0 ssh-remote+user@hostname          # Install on SSH remote"
    echo "  $0 dev-container+container-name      # Install in dev container"
    echo "  $0 wsl+distro-name                   # Install in WSL"
    echo ""
    echo "To get your current extensions list:"
    echo "  cursor --list-extensions"
}

# Function to backup existing extensions
backup_extensions() {
    local backup_dir="$HOME/.cursor-extensions-backup-$(date +%Y%m%d-%H%M%S)"
    print_status "Creating backup of current extensions in $backup_dir"
    
    if command_exists cursor; then
        mkdir -p "$backup_dir"
        cursor --list-extensions > "$backup_dir/installed-extensions.txt" 2>/dev/null || true
        print_success "Backup created"
    else
        print_warning "Cursor CLI not available, skipping backup"
    fi
}

# Function to install a single extension
install_extension() {
    local extension="$1"
    local remote_connection="$2"
    
    print_status "Installing: $extension"
    
    if [ -n "$remote_connection" ]; then
        # Install on remote instance
        if cursor --install-extension "$extension" --remote "$remote_connection" > /dev/null 2>&1; then
            print_success "Installed: $extension (remote: $remote_connection)"
            return 0
        else
            print_error "Failed to install: $extension (remote: $remote_connection)"
            return 1
        fi
    else
        # Install locally
        if cursor --install-extension "$extension" > /dev/null 2>&1; then
            print_success "Installed: $extension"
            return 0
        else
            print_error "Failed to install: $extension"
            return 1
        fi
    fi
}

# Function to install all extensions
install_all_extensions() {
    local remote_connection="$1"
    local failed_extensions=()
    
    print_status "Installing Cursor extensions..."
    print_status "Total extensions to install: ${#EXTENSIONS[@]}"
    if [ -n "$remote_connection" ]; then
        print_status "Remote connection: $remote_connection"
    else
        print_status "Installing locally"
    fi
    echo "----------------------------------------"
    
    for extension in "${EXTENSIONS[@]}"; do
        if ! install_extension "$extension" "$remote_connection"; then
            failed_extensions+=("$extension")
        fi
        echo ""
    done
    
    # Report results
    echo "----------------------------------------"
    if [ ${#failed_extensions[@]} -eq 0 ]; then
        print_success "All extensions installed successfully!"
    else
        print_warning "Some extensions failed to install:"
        for ext in "${failed_extensions[@]}"; do
            echo "  - $ext"
        done
    fi
}

# Array of extension IDs to install (updated list)
EXTENSIONS=(
    "esbenp.prettier-vscode"
    "formulahendry.docker-explorer"
    "formulahendry.docker-extension-pack"
    "golang.go"
    "ms-python.python"
    "ms-python.debugpy"
    "ms-python.python"
    "ms-python.vscode-pylance"
    "nextfaze.json-parse-stringify"
    "waderyan.gitblame"
)

# Main script logic
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_usage
    exit 0
fi

echo -e "${BLUE}🔧 Installing Cursor Extensions${NC}"
echo "=================================="

# Check if cursor CLI is available
if ! command_exists cursor; then
    print_error "cursor CLI is not installed or not in PATH"
    echo "Please install Cursor and ensure the CLI is available"
    echo "Visit: https://cursor.sh/"
    exit 1
fi

# Create backup (only for local installations)
if [ -z "$1" ]; then
    backup_extensions
fi

# Install all extensions
install_all_extensions "$1"

echo ""
echo "Installed extensions:"
for extension in "${EXTENSIONS[@]}"; do
    echo "  - $extension"
done

echo ""
print_status "To update extensions later, run: cursor --update-extensions" 