#!/bin/bash

# Quick Fix for Zsh New User Install Prompt
# This script immediately creates a .zshrc file to prevent the prompt

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

echo -e "${BLUE}🔧 Quick Fix for Zsh New User Install Prompt${NC}"
echo "=================================================="

# Create basic .zshrc immediately
zshrc_file="$HOME/.zshrc"

if [ ! -f "$zshrc_file" ]; then
    print_status "Creating basic .zshrc file..."
    cat > "$zshrc_file" << 'EOF'
# Basic zsh configuration
# Created by quick fix script

# Basic prompt
PROMPT='%n@%m %~ %# '

# Basic history settings
HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS

# Basic completions
autoload -U compinit && compinit

# This prevents the zsh-newuser-install prompt
EOF
    print_success "Basic .zshrc created at $zshrc_file"
else
    print_success ".zshrc already exists at $zshrc_file"
fi

print_success "Quick fix completed!"
echo ""
print_status "The zsh-newuser-install prompt should no longer appear."
print_status "You can now restart your terminal or run: source ~/.zshrc" 