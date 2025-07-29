#!/bin/bash

# Reload Aliases Script
# Part of the general dotfile collection
# Use this to reload aliases in your current shell session

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

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
ALIASES_FILE="$DOTFILES_DIR/.aliases"

echo -e "${BLUE}🔄 Reloading Aliases${NC}"
echo "======================"

if [ -f "$ALIASES_FILE" ]; then
    print_status "Sourcing aliases from: $ALIASES_FILE"
    source "$ALIASES_FILE"
    print_success "Aliases reloaded successfully!"
    echo ""
    print_status "Available aliases:"
    echo "  Navigation: .., ..., ...., ....., ~, -"
    echo "  Listing: l, la, ll, lsd"
    echo "  Git: g, ga, gc, gco, gcb, gcm, gd, gds, gl, gp, gpl, gs, gst"
    echo "  Docker: d, dc, dps, dpsa, di, dex"
    echo "  Development: py, pip, node, npm, yarn"
    echo "  System: c, h, j, path, now, nowtime, nowdate"
    echo "  Network: myip, ports"
    echo "  Safety: rm, cp, mv, mkdir"
    echo "  Cursor: cursor-extensions, update-cursor"
else
    print_error "Aliases file not found at: $ALIASES_FILE"
    exit 1
fi 