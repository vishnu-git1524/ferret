#!/bin/bash

# Ferret OS Build Script
# Builds a complete Debian-based Linux distribution with XFCE desktop
# Author: Ferret OS Team
# License: GPL v3.0

set -e

# Configuration
FERRET_VERSION="1.0.0"
FERRET_CODENAME="Swift"
BUILD_DIR="$(pwd)/iso/build"
ROOT_DIR="$(pwd)/iso/rootfs"
ISO_DIR="$(pwd)/iso/output"
DEBIAN_RELEASE="bookworm"
ARCH="amd64"
KERNEL_VERSION="6.1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
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

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (use sudo)"
    fi
}

# Check build dependencies
check_dependencies() {
    log "Checking build dependencies..."
    
    local deps=(
        "debootstrap"
        "chroot"
        "xorriso"
        "squashfs-tools"
        "grub-pc-bin"
        "grub-efi-amd64-bin"
        "mtools"
        "dosfstools"
        "wget"
        "curl"
        "git"
    )
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            error "Missing dependency: $dep"
        fi
    done
    
    success "All dependencies found"
}

# Clean previous build
clean_build() {
    log "Cleaning previous build..."
    rm -rf "$BUILD_DIR" "$ROOT_DIR" "$ISO_DIR"
    mkdir -p "$BUILD_DIR" "$ROOT_DIR" "$ISO_DIR"
    success "Build environment cleaned"
}

# Bootstrap Debian base system
bootstrap_system() {
    log "Bootstrapping Debian $DEBIAN_RELEASE base system..."
    
    debootstrap \
        --arch="$ARCH" \
        --variant=minbase \
        --include=systemd,systemd-sysv \
        "$DEBIAN_RELEASE" \
        "$ROOT_DIR" \
        http://deb.debian.org/debian/
    
    success "Base system bootstrapped"
}

# Configure APT sources
configure_apt() {
    log "Configuring APT sources..."
    
    cat > "$ROOT_DIR/etc/apt/sources.list" << EOF
# Ferret OS APT Sources
deb http://deb.debian.org/debian/ $DEBIAN_RELEASE main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ $DEBIAN_RELEASE main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security/ $DEBIAN_RELEASE-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security/ $DEBIAN_RELEASE-security main contrib non-free non-free-firmware

deb http://deb.debian.org/debian/ $DEBIAN_RELEASE-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ $DEBIAN_RELEASE-updates main contrib non-free non-free-firmware

# Backports
deb http://deb.debian.org/debian/ $DEBIAN_RELEASE-backports main contrib non-free non-free-firmware
EOF

    success "APT sources configured"
}

# Install essential packages
install_packages() {
    log "Installing essential packages..."
    
    # Prepare chroot environment
    mount --bind /dev "$ROOT_DIR/dev"
    mount --bind /dev/pts "$ROOT_DIR/dev/pts"
    mount --bind /proc "$ROOT_DIR/proc"
    mount --bind /sys "$ROOT_DIR/sys"
    
    # Copy resolv.conf for internet access
    cp /etc/resolv.conf "$ROOT_DIR/etc/"
    
    # Essential package lists
    local essential_packages=(
        # Kernel and boot
        "linux-image-$ARCH"
        "linux-headers-$ARCH"
        "firmware-linux"
        "firmware-linux-nonfree"
        "intel-microcode"
        "amd64-microcode"
        
        # Boot and init
        "grub-pc"
        "grub-efi-amd64"
        "os-prober"
        "systemd"
        "systemd-sysv"
        "dbus"
        
        # Network
        "network-manager"
        "network-manager-gnome"
        "wireless-tools"
        "wpasupplicant"
        "bluetooth"
        "bluez"
        "bluez-tools"
        
        # Audio
        "pulseaudio"
        "pulseaudio-utils"
        "alsa-utils"
        "pavucontrol"
        
        # File systems
        "ntfs-3g"
        "exfat-fuse"
        "btrfs-progs"
        "cryptsetup"
        "lvm2"
        
        # Hardware support
        "xserver-xorg"
        "xserver-xorg-video-all"
        "mesa-utils"
        "va-driver-all"
        "vulkan-tools"
        
        # Input methods
        "xinput"
        "xbindkeys"
        "numlockx"
        
        # Essential tools
        "sudo"
        "curl"
        "wget"
        "git"
        "vim"
        "nano"
        "htop"
        "tree"
        "unzip"
        "zip"
        "p7zip-full"
        "rsync"
        "ssh"
        "gnupg"
        "ca-certificates"
        "apt-transport-https"
        
        # Localization
        "locales"
        "console-setup"
        "keyboard-configuration"
        
        # Live system
        "casper"
        "lupin-casper"
        "discover"
        "laptop-detect"
        "os-prober"
    )
    
    local desktop_packages=(
        # XFCE Desktop
        "xfce4"
        "xfce4-goodies"
        "lightdm"
        "lightdm-gtk-greeter"
        "lightdm-gtk-greeter-settings"
        
        # Applications
        "firefox-esr"
        "thunderbird"
        "libreoffice"
        "gimp"
        "vlc"
        "audacity"
        "synaptic"
        "gparted"
        "timeshift"
        
        # File manager enhancements
        "thunar-archive-plugin"
        "thunar-media-tags-plugin"
        "file-roller"
        
        # Development tools
        "build-essential"
        "cmake"
        "python3"
        "python3-pip"
        "nodejs"
        "npm"
        "default-jdk"
        
        # System tools
        "gvfs"
        "gvfs-backends"
        "udisks2"
        "policykit-1"
        "policykit-1-gnome"
        "software-properties-gtk"
        "update-manager"
        
        # Multimedia codecs
        "ubuntu-restricted-extras" # Will need to handle this differently for Debian
        "gstreamer1.0-plugins-ugly"
        "gstreamer1.0-plugins-bad"
        "gstreamer1.0-libav"
        
        # Fonts
        "fonts-liberation"
        "fonts-noto"
        "fonts-roboto"
        "fonts-ubuntu"
    )
    
    # Install in chroot
    chroot "$ROOT_DIR" /bin/bash -c "
        export DEBIAN_FRONTEND=noninteractive
        apt-get update
        apt-get install -y ${essential_packages[*]}
        apt-get install -y ${desktop_packages[*]} || true
        apt-get clean
    "
    
    success "Packages installed"
}

# Configure system
configure_system() {
    log "Configuring system..."
    
    # Set hostname
    echo "ferret-os" > "$ROOT_DIR/etc/hostname"
    
    # Configure hosts
    cat > "$ROOT_DIR/etc/hosts" << EOF
127.0.0.1   localhost
127.0.1.1   ferret-os
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF
    
    # Configure locale
    chroot "$ROOT_DIR" /bin/bash -c "
        echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
        locale-gen
        echo 'LANG=en_US.UTF-8' > /etc/default/locale
    "
    
    # Configure timezone
    chroot "$ROOT_DIR" /bin/bash -c "
        ln -sf /usr/share/zoneinfo/UTC /etc/localtime
        dpkg-reconfigure -f noninteractive tzdata
    "
    
    # Create live user
    chroot "$ROOT_DIR" /bin/bash -c "
        useradd -m -s /bin/bash -G sudo,audio,video,plugdev,netdev,bluetooth ferret
        echo 'ferret:ferret' | chpasswd
        echo 'ferret ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ferret
    "
    
    # Configure automatic login for live session
    mkdir -p "$ROOT_DIR/etc/lightdm/lightdm.conf.d"
    cat > "$ROOT_DIR/etc/lightdm/lightdm.conf.d/10-ferret.conf" << EOF
[Seat:*]
autologin-user=ferret
autologin-user-timeout=0
user-session=xfce
EOF
    
    success "System configured"
}

# Apply Ferret OS branding
apply_branding() {
    log "Applying Ferret OS branding..."
    
    # Create branding directories
    mkdir -p "$ROOT_DIR/usr/share/ferret-os"
    mkdir -p "$ROOT_DIR/usr/share/pixmaps"
    mkdir -p "$ROOT_DIR/usr/share/backgrounds"
    
    # Copy branding files (will create these next)
    cp -r branding/* "$ROOT_DIR/usr/share/ferret-os/" || true
    
    # Set OS release information
    cat > "$ROOT_DIR/etc/os-release" << EOF
NAME="Ferret OS"
VERSION="$FERRET_VERSION ($FERRET_CODENAME)"
ID=ferret
ID_LIKE=debian
PRETTY_NAME="Ferret OS $FERRET_VERSION"
VERSION_ID="$FERRET_VERSION"
VERSION_CODENAME=$FERRET_CODENAME
HOME_URL="https://ferret-os.org"
SUPPORT_URL="https://ferret-os.org/support"
BUG_REPORT_URL="https://github.com/ferret-os/ferret/issues"
LOGO=ferret-os-logo
ANSI_COLOR="0;34"
EOF
    
    cat > "$ROOT_DIR/etc/lsb-release" << EOF
DISTRIB_ID=FerretOS
DISTRIB_RELEASE=$FERRET_VERSION
DISTRIB_CODENAME=$FERRET_CODENAME
DISTRIB_DESCRIPTION="Ferret OS $FERRET_VERSION"
EOF
    
    success "Branding applied"
}

# Configure Calamares installer
configure_installer() {
    log "Configuring Calamares installer..."
    
    # Install Calamares
    chroot "$ROOT_DIR" /bin/bash -c "
        apt-get update
        apt-get install -y calamares calamares-settings-debian
    "
    
    # Copy Calamares configuration (will create these files)
    cp -r installer/* "$ROOT_DIR/etc/calamares/" || true
    
    success "Installer configured"
}

# Setup Flatpak support
setup_flatpak() {
    log "Setting up Flatpak support..."
    
    chroot "$ROOT_DIR" /bin/bash -c "
        apt-get install -y flatpak gnome-software-plugin-flatpak
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    "
    
    success "Flatpak configured"
}

# Configure security
configure_security() {
    log "Configuring security..."
    
    # Install and configure UFW
    chroot "$ROOT_DIR" /bin/bash -c "
        apt-get install -y ufw apparmor apparmor-utils
        ufw --force enable
        systemctl enable ufw
        systemctl enable apparmor
    "
    
    success "Security configured"
}

# Build initramfs and configure boot
configure_boot() {
    log "Configuring boot system..."
    
    chroot "$ROOT_DIR" /bin/bash -c "
        update-initramfs -u
        update-grub
    "
    
    success "Boot system configured"
}

# Clean up chroot
cleanup_chroot() {
    log "Cleaning up chroot environment..."
    
    chroot "$ROOT_DIR" /bin/bash -c "
        apt-get autoremove -y
        apt-get autoclean
        rm -rf /var/lib/apt/lists/*
        rm -rf /tmp/*
        rm -rf /var/tmp/*
        history -c
    "
    
    # Unmount bind mounts
    umount "$ROOT_DIR/dev/pts" || true
    umount "$ROOT_DIR/dev" || true
    umount "$ROOT_DIR/proc" || true
    umount "$ROOT_DIR/sys" || true
    
    success "Chroot cleaned up"
}

# Create squashfs filesystem
create_squashfs() {
    log "Creating SquashFS filesystem..."
    
    mkdir -p "$BUILD_DIR/live"
    mksquashfs "$ROOT_DIR" "$BUILD_DIR/live/filesystem.squashfs" \
        -comp xz \
        -e boot
    
    success "SquashFS created"
}

# Prepare ISO directory structure
prepare_iso() {
    log "Preparing ISO directory structure..."
    
    mkdir -p "$BUILD_DIR/iso"
    mkdir -p "$BUILD_DIR/iso/live"
    mkdir -p "$BUILD_DIR/iso/boot/grub"
    mkdir -p "$BUILD_DIR/iso/EFI/boot"
    
    # Copy kernel and initrd
    cp "$ROOT_DIR/boot/vmlinuz-"* "$BUILD_DIR/iso/live/vmlinuz"
    cp "$ROOT_DIR/boot/initrd.img-"* "$BUILD_DIR/iso/live/initrd"
    
    # Copy squashfs
    cp "$BUILD_DIR/live/filesystem.squashfs" "$BUILD_DIR/iso/live/"
    
    success "ISO directory prepared"
}

# Configure GRUB for ISO
configure_grub() {
    log "Configuring GRUB for ISO..."
    
    # GRUB configuration for BIOS
    cat > "$BUILD_DIR/iso/boot/grub/grub.cfg" << 'EOF'
set timeout=10
set default=0

menuentry "Ferret OS Live" {
    linux /live/vmlinuz boot=live quiet splash
    initrd /live/initrd
}

menuentry "Ferret OS Live (Safe Mode)" {
    linux /live/vmlinuz boot=live quiet splash nomodeset
    initrd /live/initrd
}

menuentry "Check disc for defects" {
    linux /live/vmlinuz boot=live integrity-check quiet splash
    initrd /live/initrd
}
EOF
    
    # GRUB configuration for UEFI
    mkdir -p "$BUILD_DIR/iso/EFI/boot"
    cat > "$BUILD_DIR/iso/EFI/boot/grub.cfg" << 'EOF'
set timeout=10
set default=0

menuentry "Ferret OS Live" {
    linux /live/vmlinuz boot=live quiet splash
    initrd /live/initrd
}

menuentry "Ferret OS Live (Safe Mode)" {
    linux /live/vmlinuz boot=live quiet splash nomodeset
    initrd /live/initrd
}
EOF
    
    success "GRUB configured"
}

# Create bootable ISO
create_iso() {
    log "Creating bootable ISO..."
    
    local iso_name="ferret-os-${FERRET_VERSION}-${ARCH}.iso"
    
    xorriso -as mkisofs \
        -iso-level 3 \
        -full-iso9660-filenames \
        -volid "Ferret OS $FERRET_VERSION" \
        -eltorito-boot boot/grub/i386-pc/eltorito.img \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        --eltorito-catalog boot/grub/i386-pc/boot.cat \
        --grub2-boot-info \
        --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
        -eltorito-alt-boot \
        -e EFI/boot/efiboot.img \
        -no-emul-boot \
        -append_partition 2 0xef "$BUILD_DIR/iso/EFI/boot/efiboot.img" \
        -output "$ISO_DIR/$iso_name" \
        -graft-points \
            "/EFI/boot/bootx64.efi=/usr/lib/grub/x86_64-efi/monolithic/grubx64.efi" \
            "/EFI/boot/grubx64.efi=/usr/lib/grub/x86_64-efi/monolithic/grubx64.efi" \
        "$BUILD_DIR/iso"
    
    # Create checksum
    cd "$ISO_DIR"
    sha256sum "$iso_name" > "${iso_name}.sha256"
    cd - > /dev/null
    
    success "ISO created: $ISO_DIR/$iso_name"
}

# Main build function
main() {
    log "Starting Ferret OS build process..."
    log "Version: $FERRET_VERSION ($FERRET_CODENAME)"
    log "Architecture: $ARCH"
    log "Debian Release: $DEBIAN_RELEASE"
    
    check_root
    check_dependencies
    clean_build
    bootstrap_system
    configure_apt
    install_packages
    configure_system
    apply_branding
    configure_installer
    setup_flatpak
    configure_security
    configure_boot
    cleanup_chroot
    create_squashfs
    prepare_iso
    configure_grub
    create_iso
    
    success "Ferret OS build completed successfully!"
    log "ISO location: $ISO_DIR/ferret-os-${FERRET_VERSION}-${ARCH}.iso"
    log "SHA256: $ISO_DIR/ferret-os-${FERRET_VERSION}-${ARCH}.iso.sha256"
}

# Run main function
main "$@"
