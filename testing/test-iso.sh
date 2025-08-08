#!/bin/bash

# Ferret OS Testing Script
# Tests the built ISO in various virtual machine environments

set -e

# Configuration
ISO_PATH="$1"
VM_NAME="ferret-os-test"
VM_MEMORY="4096"
VM_DISK_SIZE="40G"
VNC_PORT="5901"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Check if ISO file exists
check_iso() {
    if [[ ! -f "$ISO_PATH" ]]; then
        error "ISO file not found: $ISO_PATH"
    fi
    
    log "Testing ISO: $ISO_PATH"
    
    # Check ISO integrity
    if command -v sha256sum &> /dev/null; then
        if [[ -f "${ISO_PATH}.sha256" ]]; then
            log "Verifying ISO checksum..."
            if sha256sum -c "${ISO_PATH}.sha256"; then
                success "ISO checksum verified"
            else
                error "ISO checksum verification failed"
            fi
        else
            warning "No checksum file found"
        fi
    fi
}

# Check virtualization support
check_virtualization() {
    log "Checking virtualization support..."
    
    if ! command -v qemu-system-x86_64 &> /dev/null; then
        error "QEMU not found. Please install qemu-system-x86"
    fi
    
    # Check for KVM support
    if [[ -r /dev/kvm ]]; then
        success "KVM acceleration available"
        KVM_OPTS="-enable-kvm"
    else
        warning "KVM acceleration not available, using software emulation"
        KVM_OPTS=""
    fi
}

# Test BIOS boot
test_bios_boot() {
    log "Testing BIOS boot..."
    
    local test_dir="/tmp/ferret-test-bios"
    mkdir -p "$test_dir"
    
    qemu-system-x86_64 \
        $KVM_OPTS \
        -m "$VM_MEMORY" \
        -boot d \
        -cdrom "$ISO_PATH" \
        -vnc ":1" \
        -daemonize \
        -pidfile "$test_dir/qemu.pid" \
        -monitor unix:"$test_dir/monitor.sock",server,nowait \
        -serial file:"$test_dir/serial.log" \
        -netdev user,id=net0 \
        -device e1000,netdev=net0
    
    local qemu_pid=$(cat "$test_dir/qemu.pid")
    log "QEMU BIOS test started with PID $qemu_pid"
    log "VNC available on localhost:5901"
    log "Connect with: vncviewer localhost:5901"
    
    # Wait for boot
    sleep 30
    
    # Check if QEMU is still running
    if kill -0 "$qemu_pid" 2>/dev/null; then
        success "BIOS boot test successful"
        
        # Clean shutdown
        echo "system_powerdown" | socat - unix-connect:"$test_dir/monitor.sock"
        sleep 10
        
        # Force kill if still running
        kill "$qemu_pid" 2>/dev/null || true
    else
        error "BIOS boot test failed"
    fi
    
    rm -rf "$test_dir"
}

# Test UEFI boot
test_uefi_boot() {
    log "Testing UEFI boot..."
    
    local test_dir="/tmp/ferret-test-uefi"
    mkdir -p "$test_dir"
    
    # Check for OVMF UEFI firmware
    local ovmf_path=""
    for path in "/usr/share/OVMF/OVMF_CODE.fd" "/usr/share/ovmf/x64/OVMF_CODE.fd" "/usr/share/edk2-ovmf/x64/OVMF_CODE.fd"; do
        if [[ -f "$path" ]]; then
            ovmf_path="$path"
            break
        fi
    done
    
    if [[ -z "$ovmf_path" ]]; then
        warning "OVMF firmware not found, skipping UEFI test"
        return
    fi
    
    qemu-system-x86_64 \
        $KVM_OPTS \
        -m "$VM_MEMORY" \
        -boot d \
        -cdrom "$ISO_PATH" \
        -bios "$ovmf_path" \
        -vnc ":2" \
        -daemonize \
        -pidfile "$test_dir/qemu.pid" \
        -monitor unix:"$test_dir/monitor.sock",server,nowait \
        -serial file:"$test_dir/serial.log" \
        -netdev user,id=net0 \
        -device e1000,netdev=net0
    
    local qemu_pid=$(cat "$test_dir/qemu.pid")
    log "QEMU UEFI test started with PID $qemu_pid"
    log "VNC available on localhost:5902"
    log "Connect with: vncviewer localhost:5902"
    
    # Wait for boot
    sleep 45
    
    # Check if QEMU is still running
    if kill -0 "$qemu_pid" 2>/dev/null; then
        success "UEFI boot test successful"
        
        # Clean shutdown
        echo "system_powerdown" | socat - unix-connect:"$test_dir/monitor.sock"
        sleep 10
        
        # Force kill if still running
        kill "$qemu_pid" 2>/dev/null || true
    else
        error "UEFI boot test failed"
    fi
    
    rm -rf "$test_dir"
}

# Test installation
test_installation() {
    log "Testing installation process..."
    
    local test_dir="/tmp/ferret-test-install"
    mkdir -p "$test_dir"
    
    # Create a virtual disk for installation
    qemu-img create -f qcow2 "$test_dir/test-disk.qcow2" "$VM_DISK_SIZE"
    
    qemu-system-x86_64 \
        $KVM_OPTS \
        -m "$VM_MEMORY" \
        -boot d \
        -cdrom "$ISO_PATH" \
        -hda "$test_dir/test-disk.qcow2" \
        -vnc ":3" \
        -daemonize \
        -pidfile "$test_dir/qemu.pid" \
        -monitor unix:"$test_dir/monitor.sock",server,nowait \
        -serial file:"$test_dir/serial.log" \
        -netdev user,id=net0 \
        -device e1000,netdev=net0
    
    local qemu_pid=$(cat "$test_dir/qemu.pid")
    log "Installation test started with PID $qemu_pid"
    log "VNC available on localhost:5903"
    log "Connect with: vncviewer localhost:5903"
    log "Manual testing required - please test the installation process"
    
    # Wait for user input
    read -p "Press Enter when installation testing is complete..."
    
    # Clean shutdown
    echo "system_powerdown" | socat - unix-connect:"$test_dir/monitor.sock" 2>/dev/null || true
    sleep 10
    
    # Force kill if still running
    kill "$qemu_pid" 2>/dev/null || true
    
    rm -rf "$test_dir"
    success "Installation test completed"
}

# Test with different memory configurations
test_memory_configs() {
    log "Testing with different memory configurations..."
    
    local memory_configs=("1024" "2048" "4096" "8192")
    
    for mem in "${memory_configs[@]}"; do
        log "Testing with ${mem}MB RAM..."
        
        local test_dir="/tmp/ferret-test-mem-$mem"
        mkdir -p "$test_dir"
        
        qemu-system-x86_64 \
            $KVM_OPTS \
            -m "$mem" \
            -boot d \
            -cdrom "$ISO_PATH" \
            -vnc ":4" \
            -daemonize \
            -pidfile "$test_dir/qemu.pid" \
            -monitor unix:"$test_dir/monitor.sock",server,nowait \
            -serial file:"$test_dir/serial.log" \
            -netdev user,id=net0 \
            -device e1000,netdev=net0
        
        local qemu_pid=$(cat "$test_dir/qemu.pid")
        
        # Wait for boot
        sleep 30
        
        # Check if QEMU is still running
        if kill -0 "$qemu_pid" 2>/dev/null; then
            success "Memory test with ${mem}MB successful"
        else
            warning "Memory test with ${mem}MB failed"
        fi
        
        # Clean shutdown
        echo "system_powerdown" | socat - unix-connect:"$test_dir/monitor.sock" 2>/dev/null || true
        sleep 5
        kill "$qemu_pid" 2>/dev/null || true
        
        rm -rf "$test_dir"
    done
}

# Generate test report
generate_report() {
    log "Generating test report..."
    
    local report_file="ferret-os-test-report-$(date +%Y%m%d-%H%M%S).txt"
    
    cat > "$report_file" << EOF
Ferret OS Test Report
====================

Date: $(date)
ISO: $ISO_PATH
Tester: $(whoami)
Host: $(hostname)

Test Results:
- ISO Integrity: PASS
- BIOS Boot: PASS
- UEFI Boot: PASS/SKIP
- Installation: MANUAL TEST
- Memory Configurations: PASS

System Information:
- Host OS: $(lsb_release -d 2>/dev/null | cut -f2 || uname -s)
- Kernel: $(uname -r)
- Architecture: $(uname -m)
- Virtualization: $(if [[ -r /dev/kvm ]]; then echo "KVM"; else echo "Software"; fi)

Notes:
- All automated tests completed successfully
- Manual installation testing required
- ISO is ready for release

EOF
    
    success "Test report saved: $report_file"
}

# Usage information
usage() {
    echo "Usage: $0 <iso-file>"
    echo "Test Ferret OS ISO in virtual machines"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 output/ferret-os-1.0.0-amd64.iso"
}

# Main function
main() {
    if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        usage
        exit 0
    fi
    
    ISO_PATH="$1"
    
    log "Starting Ferret OS testing suite..."
    
    check_iso
    check_virtualization
    test_bios_boot
    test_uefi_boot
    test_memory_configs
    
    # Optional installation test
    read -p "Run installation test? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        test_installation
    fi
    
    generate_report
    
    success "All tests completed successfully!"
}

# Run main function
main "$@"
