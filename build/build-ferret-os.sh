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

# Install build dependencies
install_build_dependencies() {
    log "Installing build dependencies..."
    
    # Update package lists first
    apt-get update
    
    local deps=(
        "debootstrap"
        "squashfs-tools"
        "xorriso"
        "grub-pc-bin"
        "grub-efi-amd64-bin"
        "grub-efi-ia32-bin"
        "mtools"
        "dosfstools"
        "wget"
        "curl"
        "git"
        "isolinux"
        "syslinux-efi"
        "genisoimage"
        "rsync"
        "live-build"
    )
    
    log "Installing: ${deps[*]}"
    apt-get install -y "${deps[@]}"
    
    success "All dependencies installed"
}

# Check build dependencies
check_dependencies() {
    log "Checking build dependencies..."
    
    local missing_deps=()
    local deps=(
        "debootstrap"
        "mksquashfs"
        "xorriso"
    )
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        warning "Missing dependencies: ${missing_deps[*]}"
        install_build_dependencies
    else
        success "All dependencies found"
    fi
}

# Clean previous build
clean_build() {
    log "Cleaning previous build..."
    
    # Unmount any existing bind mounts
    umount "$ROOT_DIR/dev/pts" 2>/dev/null || true
    umount "$ROOT_DIR/dev" 2>/dev/null || true
    umount "$ROOT_DIR/proc" 2>/dev/null || true
    umount "$ROOT_DIR/sys" 2>/dev/null || true
    umount "$ROOT_DIR/run" 2>/dev/null || true
    
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
        --include=systemd,systemd-sysv,dbus,apt-utils,ca-certificates \
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
    mount --bind /run "$ROOT_DIR/run"
    
    # Copy resolv.conf for internet access
    cp /etc/resolv.conf "$ROOT_DIR/etc/"
    
    # Determine correct kernel package name for architecture
    local kernel_image="linux-image-amd64"
    local kernel_headers="linux-headers-amd64"
    local microcode_pkg=""
    
    if [[ "$ARCH" == "amd64" ]]; then
        kernel_image="linux-image-amd64"
        kernel_headers="linux-headers-amd64"
        microcode_pkg="intel-microcode amd64-microcode"
    elif [[ "$ARCH" == "i386" ]]; then
        kernel_image="linux-image-686-pae"
        kernel_headers="linux-headers-686-pae"
        microcode_pkg="intel-microcode"
    fi
    
    # Essential package lists
    local essential_packages=(
        # Kernel and boot
        "$kernel_image"
        "$kernel_headers"
        "firmware-linux"
        "firmware-linux-nonfree"
        $microcode_pkg
        
        # Boot and init
        "grub-pc"
        "grub-efi-amd64"
        "grub-common"
        "os-prober"
        "systemd"
        "systemd-sysv"
        "dbus"
        "initramfs-tools"
        
        # Live system essentials
        "live-boot"
        "live-config"
        "live-config-systemd"
        
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
        "openssh-client"
        "gnupg"
        "ca-certificates"
        "apt-transport-https"
        
        # Localization
        "locales"
        "console-setup"
        "keyboard-configuration"
        
        # System utilities
        "udev"
        "util-linux"
        "mount"
        "psmisc"
        "procps"
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
        
        # Multimedia codecs (Debian equivalents)
        "gstreamer1.0-plugins-ugly"
        "gstreamer1.0-plugins-bad"
        "gstreamer1.0-libav"
        "libavcodec-extra58"
        
        # Fonts
        "fonts-liberation"
        "fonts-noto"
        "fonts-dejavu"
        "fonts-liberation2"
    )
    
    # Install in chroot with better error handling
    chroot "$ROOT_DIR" /bin/bash -c "
        export DEBIAN_FRONTEND=noninteractive
        export APT_LISTCHANGES_FRONTEND=none
        
        # Update package lists
        apt-get update
        
        # Install essential packages first with individual error handling
        echo 'Installing essential packages...'
        for pkg in ${essential_packages[*]}; do
            echo \"Installing \$pkg...\"
            apt-get install -y \"\$pkg\" || {
                echo \"Failed to install \$pkg, skipping...\"
            }
        done
        
        # Install desktop packages with individual error handling
        echo 'Installing desktop packages...'
        for pkg in ${desktop_packages[*]}; do
            echo \"Installing \$pkg...\"
            apt-get install -y \"\$pkg\" || {
                echo \"Failed to install \$pkg, skipping...\"
            }
        done
        
        # Install additional useful packages
        echo 'Installing additional packages...'
        apt-get install -y gnome-software || apt-get install -y synaptic
        apt-get install -y gnome-software-plugin-flatpak || echo 'Flatpak plugin not available'
        apt-get install -y flatpak || echo 'Flatpak not available'
        apt-get install -y calamares || echo 'Calamares not available'
        apt-get install -y calamares-settings-debian || echo 'Calamares settings not available'
        
        # Try to install some useful alternatives if main packages failed
        apt-get install -y mousepad || apt-get install -y gedit || apt-get install -y nano
        apt-get install -y file-roller || apt-get install -y ark
        apt-get install -y network-manager-gnome || apt-get install -y wicd-gtk
        
        # Clean up
        apt-get autoremove -y
        apt-get autoclean
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
        update-locale LANG=en_US.UTF-8
    "
    
    # Configure timezone
    chroot "$ROOT_DIR" /bin/bash -c "
        ln -sf /usr/share/zoneinfo/UTC /etc/localtime
        echo 'UTC' > /etc/timezone
        dpkg-reconfigure -f noninteractive tzdata
    "
    
    # Create live user with proper groups
    chroot "$ROOT_DIR" /bin/bash -c "
        # Create user groups first
        groupadd -f audio
        groupadd -f video
        groupadd -f plugdev
        groupadd -f netdev
        groupadd -f bluetooth
        groupadd -f sudo
        
        # Create ferret user
        useradd -m -s /bin/bash ferret
        usermod -a -G sudo,audio,video,plugdev,netdev,bluetooth,cdrom,floppy,dialout ferret
        echo 'ferret:ferret' | chpasswd
        
        # Configure sudo access
        echo 'ferret ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ferret
        chmod 440 /etc/sudoers.d/ferret
    "
    
    # Configure automatic login for live session
    mkdir -p "$ROOT_DIR/etc/lightdm/lightdm.conf.d"
    cat > "$ROOT_DIR/etc/lightdm/lightdm.conf.d/10-ferret.conf" << EOF
[Seat:*]
autologin-user=ferret
autologin-user-timeout=0
user-session=xfce
greeter-hide-users=false
EOF
    
    # Configure live system
    cat > "$ROOT_DIR/etc/live/config.conf" << EOF
LIVE_HOSTNAME="ferret-os"
LIVE_USERNAME="ferret"
LIVE_USER_FULLNAME="Ferret OS User"
LIVE_USER_DEFAULT_GROUPS="audio,cdrom,dip,floppy,video,plugdev,netdev,powerdev,scanner,bluetooth,sudo"
EOF
    
    # Enable systemd services
    chroot "$ROOT_DIR" /bin/bash -c "
        systemctl enable NetworkManager
        systemctl enable bluetooth
        systemctl enable lightdm
        systemctl enable systemd-timesyncd
    "
    
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
    
    # Configure initramfs
    chroot "$ROOT_DIR" /bin/bash -c "
        # Configure initramfs for live boot
        echo 'BOOT=live' >> /etc/initramfs-tools/initramfs.conf
        echo 'MODULES=most' >> /etc/initramfs-tools/initramfs.conf
        
        # Add live boot components
        echo 'live-boot' >> /etc/initramfs-tools/modules
        echo 'overlay' >> /etc/initramfs-tools/modules
        echo 'squashfs' >> /etc/initramfs-tools/modules
        
        # Update initramfs
        update-initramfs -c -k all
        
        # Configure GRUB
        echo 'GRUB_DISTRIBUTOR=\"Ferret OS\"' >> /etc/default/grub
        echo 'GRUB_DEFAULT=0' >> /etc/default/grub
        echo 'GRUB_TIMEOUT=10' >> /etc/default/grub
        echo 'GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"' >> /etc/default/grub
        
        # Generate GRUB configuration
        update-grub || echo 'GRUB update failed, continuing...'
    "
    
    success "Boot system configured"
}

# Clean up chroot
cleanup_chroot() {
    log "Cleaning up chroot environment..."
    
    chroot "$ROOT_DIR" /bin/bash -c "
        # Clean package cache
        apt-get autoremove -y
        apt-get autoclean
        apt-get clean
        
        # Remove temporary files
        rm -rf /var/lib/apt/lists/*
        rm -rf /tmp/*
        rm -rf /var/tmp/*
        rm -rf /var/cache/apt/*
        rm -rf /var/log/*.log
        
        # Clear bash history
        history -c || true
        rm -f /root/.bash_history
        rm -f /home/ferret/.bash_history
    "
    
    # Remove resolv.conf
    rm -f "$ROOT_DIR/etc/resolv.conf"
    
    # Unmount bind mounts in correct order
    umount "$ROOT_DIR/run" 2>/dev/null || true
    umount "$ROOT_DIR/dev/pts" 2>/dev/null || true
    umount "$ROOT_DIR/dev" 2>/dev/null || true
    umount "$ROOT_DIR/proc" 2>/dev/null || true
    umount "$ROOT_DIR/sys" 2>/dev/null || true
    
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
    mkdir -p "$BUILD_DIR/iso/isolinux"
    mkdir -p "$BUILD_DIR/iso/EFI/boot"
    
    # Find and copy kernel and initrd
    local kernel_file=$(find "$ROOT_DIR/boot" -name "vmlinuz-*" | head -1)
    local initrd_file=$(find "$ROOT_DIR/boot" -name "initrd.img-*" | head -1)
    
    if [[ -f "$kernel_file" ]]; then
        cp "$kernel_file" "$BUILD_DIR/iso/live/vmlinuz"
        log "Kernel copied: $(basename $kernel_file)"
    else
        error "Kernel not found in $ROOT_DIR/boot/"
    fi
    
    if [[ -f "$initrd_file" ]]; then
        cp "$initrd_file" "$BUILD_DIR/iso/live/initrd"
        log "Initrd copied: $(basename $initrd_file)"
    else
        error "Initrd not found in $ROOT_DIR/boot/"
    fi
    
    # Copy squashfs
    cp "$BUILD_DIR/live/filesystem.squashfs" "$BUILD_DIR/iso/live/"
    
    # Copy GRUB files for BIOS boot
    if [[ -d /usr/lib/grub/i386-pc ]]; then
        cp -r /usr/lib/grub/i386-pc "$BUILD_DIR/iso/boot/grub/"
    fi
    
    # Copy isolinux files for legacy boot
    if [[ -f /usr/lib/ISOLINUX/isolinux.bin ]]; then
        cp /usr/lib/ISOLINUX/isolinux.bin "$BUILD_DIR/iso/isolinux/"
        cp /usr/lib/syslinux/modules/bios/ldlinux.c32 "$BUILD_DIR/iso/isolinux/"
        cp /usr/lib/syslinux/modules/bios/libcom32.c32 "$BUILD_DIR/iso/isolinux/"
        cp /usr/lib/syslinux/modules/bios/libutil.c32 "$BUILD_DIR/iso/isolinux/"
        cp /usr/lib/syslinux/modules/bios/vesamenu.c32 "$BUILD_DIR/iso/isolinux/"
    fi
    
    success "ISO directory prepared"
}

# Configure GRUB for ISO
configure_grub() {
    log "Configuring GRUB for ISO..."
    
    # GRUB configuration for BIOS boot
    cat > "$BUILD_DIR/iso/boot/grub/grub.cfg" << 'EOF'
set timeout=10
set default=0

menuentry "Ferret OS Live" {
    linux /live/vmlinuz boot=live components quiet splash
    initrd /live/initrd
}

menuentry "Ferret OS Live (Safe Mode)" {
    linux /live/vmlinuz boot=live components quiet splash nomodeset
    initrd /live/initrd
}

menuentry "Ferret OS Live (Persistent)" {
    linux /live/vmlinuz boot=live components persistent quiet splash
    initrd /live/initrd
}

menuentry "Memory Test (if available)" {
    linux16 /boot/memtest86+.bin
}
EOF
    
    # Isolinux configuration for legacy systems
    cat > "$BUILD_DIR/iso/isolinux/isolinux.cfg" << 'EOF'
UI vesamenu.c32
MENU TITLE Ferret OS Boot Menu
MENU BACKGROUND splash.png
TIMEOUT 100
DEFAULT live

LABEL live
    MENU LABEL Ferret OS Live
    KERNEL /live/vmlinuz
    APPEND initrd=/live/initrd boot=live components quiet splash

LABEL safe
    MENU LABEL Ferret OS Live (Safe Mode)
    KERNEL /live/vmlinuz
    APPEND initrd=/live/initrd boot=live components quiet splash nomodeset

LABEL persistent
    MENU LABEL Ferret OS Live (Persistent)
    KERNEL /live/vmlinuz
    APPEND initrd=/live/initrd boot=live components persistent quiet splash
EOF
    
    # UEFI boot configuration
    mkdir -p "$BUILD_DIR/iso/EFI/boot"
    
    # Create minimal GRUB EFI configuration
    cat > "$BUILD_DIR/iso/EFI/boot/grub.cfg" << 'EOF'
set timeout=10
set default=0

menuentry "Ferret OS Live (UEFI)" {
    linux /live/vmlinuz boot=live components quiet splash
    initrd /live/initrd
}

menuentry "Ferret OS Live (UEFI Safe Mode)" {
    linux /live/vmlinuz boot=live components quiet splash nomodeset
    initrd /live/initrd
}
EOF
    
    # Copy EFI boot files if available
    if [[ -f /usr/lib/grub/x86_64-efi/monolithic/grubx64.efi ]]; then
        cp /usr/lib/grub/x86_64-efi/monolithic/grubx64.efi "$BUILD_DIR/iso/EFI/boot/bootx64.efi"
    elif [[ -f /usr/lib/grub/x86_64-efi/grub.efi ]]; then
        cp /usr/lib/grub/x86_64-efi/grub.efi "$BUILD_DIR/iso/EFI/boot/bootx64.efi"
    fi
    
    success "GRUB configured"
}

# Create bootable ISO
create_iso() {
    log "Creating bootable ISO..."
    
    local iso_name="ferret-os-${FERRET_VERSION}-${ARCH}.iso"
    
    # Use xorriso to create hybrid ISO
    xorriso -as mkisofs \
        -iso-level 3 \
        -full-iso9660-filenames \
        -volid "FERRET_OS_${FERRET_VERSION}" \
        -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
        -eltorito-boot isolinux/isolinux.bin \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        -eltorito-alt-boot \
        -e EFI/boot/efiboot.img \
        -no-emul-boot \
        -isohybrid-gpt-basdat \
        -output "$ISO_DIR/$iso_name" \
        "$BUILD_DIR/iso" 2>/dev/null || {
        
        # Fallback to even simpler method if ISOLINUX path doesn't exist
        warning "Advanced ISO creation failed, trying simple method..."
        
        if [[ -f /usr/lib/ISOLINUX/isohdpfx.bin ]]; then
            genisoimage \
                -o "$ISO_DIR/$iso_name" \
                -b isolinux/isolinux.bin \
                -c isolinux/boot.cat \
                -no-emul-boot \
                -boot-load-size 4 \
                -boot-info-table \
                -J -R -V "FERRET_OS_${FERRET_VERSION}" \
                "$BUILD_DIR/iso"
        else
            # Very basic ISO without isolinux
            genisoimage \
                -o "$ISO_DIR/$iso_name" \
                -J -R -V "FERRET_OS_${FERRET_VERSION}" \
                "$BUILD_DIR/iso"
        fi
    }
    
    # Make ISO bootable from USB
    if command -v isohybrid &> /dev/null; then
        isohybrid "$ISO_DIR/$iso_name" 2>/dev/null || true
    fi
    
    # Create checksum
    cd "$ISO_DIR"
    sha256sum "$iso_name" > "${iso_name}.sha256"
    cd - > /dev/null
    
    # Show ISO size
    local iso_size=$(du -h "$ISO_DIR/$iso_name" | cut -f1)
    success "ISO created: $ISO_DIR/$iso_name ($iso_size)"
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
