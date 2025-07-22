#!/bin/bash

# Cursor Extensions Installer
# Part of the general dotfile collection
# Inspired by https://github.com/mathiasbynens/dotfiles

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
    print_status "Installing: $extension"
    if cursor --install-extension "$extension" > /dev/null 2>&1; then
        print_success "Installed: $extension"
        return 0
    else
        print_error "Failed to install: $extension"
        return 1
    fi
}

# Function to install all extensions
install_all_extensions() {
    local failed_extensions=()
    
    for extension in "${EXTENSIONS[@]}"; do
        if ! install_extension "$extension"; then
            failed_extensions+=("$extension")
        fi
    done
    
    # Report results
    echo ""
    if [ ${#failed_extensions[@]} -eq 0 ]; then
        print_success "All extensions installed successfully!"
    else
        print_warning "Some extensions failed to install:"
        for ext in "${failed_extensions[@]}"; do
            echo "  - $ext"
        done
    fi
}

# Array of extension IDs to install
EXTENSIONS=(
    "esbenp.prettier-vscode"
    "formulahendry.docker-explorer"
    "formulahendry.docker-extension-pack"
    "golang.go"
    "ms-python.python"
    "ms-python.debugpy"
    "ms-python.vscode-pylance"
    "nextfaze.json-parse-stringify"
    "waderyan.gitblame"
)

echo -e "${BLUE}🔧 Installing Cursor Extensions${NC}"
echo "=================================="

# Check if cursor CLI is available
if ! command_exists cursor; then
    print_error "cursor CLI is not installed or not in PATH"
    echo "Please install Cursor and ensure the CLI is available"
    echo "Visit: https://cursor.sh/"
    exit 1
fi

# Create backup
backup_extensions

# Install all extensions
install_all_extensions

echo ""
echo "Installed extensions:"
for extension in "${EXTENSIONS[@]}"; do
    echo "  - $extension"
done

echo ""
print_status "To update extensions later, run: cursor --update-extensions" 