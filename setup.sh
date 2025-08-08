#!/bin/bash

# Ferret OS Quick Setup Script
# Prepares build environment and starts the build process

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Project information
PROJECT_NAME="Ferret OS"
PROJECT_VERSION="1.0.0"
PROJECT_REPO="https://github.com/ferret-os/ferret.git"

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Display banner
show_banner() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                         Ferret OS                           ║
║              Fast, Reliable, Modern Linux                   ║
║                                                              ║
║         Build System Setup and Quick Start                  ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo
    echo -e "${BLUE}Version:${NC} $PROJECT_VERSION"
    echo -e "${BLUE}Target:${NC} Complete Linux Distribution ISO"
    echo -e "${BLUE}Base:${NC} Debian with XFCE Desktop"
    echo
}

# Check system requirements
check_requirements() {
    log "Checking system requirements..."
    
    # Check OS
    if [[ ! -f /etc/debian_version ]] && [[ ! -f /etc/lsb-release ]]; then
        warning "This script is designed for Debian/Ubuntu systems"
        warning "Other distributions may work but are not officially supported"
    fi
    
    # Check architecture
    if [[ "$(uname -m)" != "x86_64" ]]; then
        error "Only x86_64 architecture is supported"
    fi
    
    # Check available space
    local available_space=$(df . | awk 'NR==2 {print $4}')
    local required_space=$((50 * 1024 * 1024)) # 50GB in KB
    
    if [[ $available_space -lt $required_space ]]; then
        error "Insufficient disk space. Required: 50GB, Available: $((available_space / 1024 / 1024))GB"
    fi
    
    # Check memory
    local available_memory=$(free -m | awk 'NR==2{print $2}')
    if [[ $available_memory -lt 4096 ]]; then
        warning "Less than 4GB RAM available. Build may be slower."
    fi
    
    success "System requirements check passed"
}

# Install build dependencies
install_dependencies() {
    log "Installing build dependencies..."
    
    # Update package lists
    if ! sudo apt update; then
        error "Failed to update package lists"
    fi
    
    # Required packages
    local packages=(
        "debootstrap"
        "squashfs-tools"
        "xorriso"
        "grub-pc-bin"
        "grub-efi-amd64-bin"
        "mtools"
        "dosfstools"
        "git"
        "curl"
        "wget"
        "qemu-system-x86"
        "qemu-utils"
        "ovmf"
        "socat"
        "build-essential"
        "python3"
        "python3-tk"
    )
    
    log "Installing packages: ${packages[*]}"
    
    if sudo apt install -y "${packages[@]}"; then
        success "Dependencies installed successfully"
    else
        error "Failed to install dependencies"
    fi
}

# Verify tools
verify_tools() {
    log "Verifying installed tools..."
    
    local tools=(
        "debootstrap"
        "mksquashfs"
        "xorriso"
        "grub-mkrescue"
        "qemu-system-x86_64"
    )
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            log "✓ $tool found"
        else
            error "✗ $tool not found"
        fi
    done
    
    success "All tools verified"
}

# Setup build environment
setup_environment() {
    log "Setting up build environment..."
    
    # Make scripts executable
    chmod +x build/build-ferret-os.sh
    chmod +x testing/test-iso.sh
    chmod +x config/xfce-config.sh
    
    # Create output directories
    mkdir -p iso/build iso/rootfs iso/output
    mkdir -p testing/results
    
    # Set up Python path for welcome app
    if [[ ! -f /usr/local/bin/ferret-welcome ]]; then
        log "Installing Ferret Welcome application..."
        sudo cp packages/ferret-welcome.py /usr/local/bin/ferret-welcome
        sudo chmod +x /usr/local/bin/ferret-welcome
    fi
    
    success "Build environment configured"
}

# Show build options
show_build_options() {
    echo
    log "Build Options:"
    echo "1. Quick Build - Build with default settings"
    echo "2. Custom Build - Configure build options"
    echo "3. Development Build - Build with debug symbols"
    echo "4. Minimal Build - Minimal system without desktop"
    echo "5. Exit - Exit without building"
    echo
}

# Quick build
quick_build() {
    log "Starting quick build with default settings..."
    log "This will create Ferret OS 1.0.0 with XFCE desktop"
    
    read -p "Continue with quick build? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Build cancelled"
        return
    fi
    
    sudo ./build/build-ferret-os.sh
}

# Custom build
custom_build() {
    log "Custom build configuration..."
    
    # Version
    read -p "Enter version (default: 1.0.0): " version
    version=${version:-1.0.0}
    export FERRET_VERSION="$version"
    
    # Codename
    read -p "Enter codename (default: Swift): " codename
    codename=${codename:-Swift}
    export FERRET_CODENAME="$codename"
    
    # Architecture
    echo "Available architectures: amd64"
    read -p "Enter architecture (default: amd64): " arch
    arch=${arch:-amd64}
    export ARCH="$arch"
    
    # Debian release
    echo "Available releases: bookworm, bullseye"
    read -p "Enter Debian release (default: bookworm): " release
    release=${release:-bookworm}
    export DEBIAN_RELEASE="$release"
    
    log "Building Ferret OS $version ($codename) for $arch based on Debian $release"
    
    read -p "Start build? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo -E ./build/build-ferret-os.sh
    fi
}

# Development build
development_build() {
    log "Development build - includes debug symbols and development tools"
    
    export FERRET_VERSION="1.0.0-dev"
    export FERRET_CODENAME="Development"
    export BUILD_TYPE="development"
    
    sudo -E ./build/build-ferret-os.sh
}

# Minimal build
minimal_build() {
    log "Minimal build - command line only, no desktop environment"
    
    export FERRET_VERSION="1.0.0-minimal"
    export FERRET_CODENAME="Minimal"
    export BUILD_TYPE="minimal"
    
    sudo -E ./build/build-ferret-os.sh
}

# Test built ISO
test_iso() {
    local iso_file
    
    # Find latest ISO
    iso_file=$(find iso/output -name "*.iso" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2-)
    
    if [[ -z "$iso_file" ]]; then
        error "No ISO file found in iso/output/"
    fi
    
    log "Testing ISO: $iso_file"
    ./testing/test-iso.sh "$iso_file"
}

# Main menu
main_menu() {
    while true; do
        show_build_options
        read -p "Select option (1-5): " choice
        
        case $choice in
            1)
                quick_build
                break
                ;;
            2)
                custom_build
                break
                ;;
            3)
                development_build
                break
                ;;
            4)
                minimal_build
                break
                ;;
            5)
                log "Exiting..."
                exit 0
                ;;
            *)
                warning "Invalid option. Please select 1-5."
                ;;
        esac
    done
    
    # Ask if user wants to test the ISO
    if [[ -d iso/output ]] && [[ -n "$(ls -A iso/output/*.iso 2>/dev/null)" ]]; then
        echo
        read -p "Test the built ISO? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            test_iso
        fi
    fi
}

# Show completion message
show_completion() {
    echo
    success "Build process completed!"
    
    if [[ -d iso/output ]] && [[ -n "$(ls -A iso/output/*.iso 2>/dev/null)" ]]; then
        echo
        log "Built ISO files:"
        ls -lh iso/output/
        echo
        log "Next steps:"
        echo "1. Test the ISO: ./testing/test-iso.sh iso/output/ferret-os-*.iso"
        echo "2. Create bootable USB: dd if=iso/output/ferret-os-*.iso of=/dev/sdX bs=4M"
        echo "3. Verify checksum: sha256sum -c iso/output/ferret-os-*.iso.sha256"
        echo
        log "Documentation available at: docs/BUILD.md"
    fi
}

# Main execution
main() {
    show_banner
    
    log "Starting Ferret OS build system setup..."
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        error "Do not run this script as root. Use sudo when prompted."
    fi
    
    check_requirements
    install_dependencies
    verify_tools
    setup_environment
    
    success "Build environment setup completed!"
    
    main_menu
    show_completion
}

# Handle interrupts
trap 'echo; error "Build interrupted by user"' INT TERM

# Run main function
main "$@"
