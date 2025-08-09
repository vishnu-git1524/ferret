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
        "imagemagick"
        "plymouth"
        "plymouth-themes"
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
        "systemd-timesyncd"
        "dbus"
        "initramfs-tools"
        
        # Live system essentials
        "live-boot"
        "live-config"
        "live-config-systemd"
        
        # Network and WiFi support
        "network-manager"
        "network-manager-gnome"
        "wireless-tools"
        "wpasupplicant"
        "firmware-iwlwifi"
        "firmware-realtek"
        "firmware-atheros"
        "firmware-brcm80211"
        "rfkill"
        "iw"
        "bluetooth"
        "bluez"
        "bluez-tools"
        "blueman"
        
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
        # XFCE Desktop - Modern version
        "xfce4"
        "xfce4-goodies"
        "xfce4-panel"
        "xfce4-settings"
        "xfce4-session"
        "xfce4-terminal"
        "xfce4-taskmanager"
        "xfce4-power-manager"
        "xfce4-screenshooter"
        "xfce4-whiskermenu-plugin"
        "lightdm"
        "lightdm-gtk-greeter"
        "lightdm-gtk-greeter-settings"
        "arc-theme"
        "papirus-icon-theme"
        "numix-gtk-theme"
        
        # Modern Applications
        "firefox-esr"
        "thunderbird"
        "libreoffice"
        "gimp"
        "vlc"
        "audacity"
        "synaptic"
        "gparted"
        "code"
        "telegram-desktop"
        
        # File manager enhancements
        "thunar-archive-plugin"
        "thunar-media-tags-plugin"
        "file-roller"
        "engrampa"
        
        # Development tools
        "build-essential"
        "cmake"
        "python3"
        "python3-pip"
        "nodejs"
        "npm"
        "default-jdk"
        "git"
        "curl"
        "wget"
        
        # System tools
        "gvfs"
        "gvfs-backends"
        "udisks2"
        "policykit-1"
        "policykit-1-gnome"
        "software-properties-gtk"
        "menulibre"
        "dconf-editor"
        
        # Multimedia codecs
        "gstreamer1.0-plugins-ugly"
        "gstreamer1.0-plugins-bad"
        "gstreamer1.0-libav"
        "libavcodec-extra"
        "ffmpeg"
        
        # Modern fonts
        "fonts-liberation"
        "fonts-noto"
        "fonts-noto-color-emoji"
        "fonts-dejavu"
        "fonts-liberation2"
        "fonts-roboto"
        "fonts-ubuntu"
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
        
        # Install WiFi and hardware support packages
        apt-get install -y firmware-linux-free firmware-linux-nonfree || echo 'Firmware packages not available'
        apt-get install -y firmware-misc-nonfree || echo 'Misc firmware not available'
        
        # Try to install some useful alternatives if main packages failed
        apt-get install -y mousepad || apt-get install -y gedit || apt-get install -y nano
        apt-get install -y file-roller || apt-get install -y ark
        apt-get install -y network-manager-gnome || apt-get install -y wicd-gtk
        
        # Enable live system services
        systemctl enable live-config
        systemctl enable NetworkManager
        
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
        systemctl enable NetworkManager-wait-online
        systemctl enable bluetooth
        systemctl enable lightdm
        systemctl enable systemd-timesyncd
        systemctl enable systemd-resolved
        
        # Ensure NetworkManager manages all interfaces
        cat > /etc/NetworkManager/NetworkManager.conf << 'NM_EOF'
[main]
plugins=ifupdown,keyfile
dns=systemd-resolved

[ifupdown]
managed=true

[device]
wifi.scan-rand-mac-address=no
NM_EOF

        # Configure systemd-resolved
        ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
        
        # Configure modern desktop theme
        mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml
        mkdir -p /home/ferret/.config/xfce4/xfconf/xfce-perchannel-xml
        
        # Set Arc theme as default
        cat > /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml << 'THEME_EOF'
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<channel name=\"xsettings\" version=\"1.0\">
  <property name=\"Net\" type=\"empty\">
    <property name=\"ThemeName\" type=\"string\" value=\"Arc-Dark\"/>
    <property name=\"IconThemeName\" type=\"string\" value=\"Papirus-Dark\"/>
    <property name=\"DoubleClickTime\" type=\"int\" value=\"400\"/>
    <property name=\"DoubleClickDistance\" type=\"int\" value=\"5\"/>
    <property name=\"DndDragThreshold\" type=\"int\" value=\"8\"/>
  </property>
  <property name=\"Gtk\" type=\"empty\">
    <property name=\"CanChangeAccels\" type=\"bool\" value=\"false\"/>
    <property name=\"ColorPalette\" type=\"string\" value=\"black:white:gray50:red:purple:blue:light blue:green:yellow:orange:lavender:brown:goldenrod4:dodger blue:pink:light green:gray10:gray30:gray75:gray90\"/>
    <property name=\"FontName\" type=\"string\" value=\"Noto Sans 10\"/>
    <property name=\"IconSizes\" type=\"string\" value=\"\"/>
    <property name=\"KeyThemeName\" type=\"string\" value=\"\"/>
    <property name=\"ToolbarStyle\" type=\"string\" value=\"icons\"/>
    <property name=\"ToolbarIconSize\" type=\"int\" value=\"3\"/>
    <property name=\"MenuImages\" type=\"bool\" value=\"true\"/>
    <property name=\"ButtonImages\" type=\"bool\" value=\"true\"/>
    <property name=\"MenuBarAccel\" type=\"string\" value=\"F10\"/>
    <property name=\"CursorThemeName\" type=\"string\" value=\"\"/>
    <property name=\"CursorThemeSize\" type=\"int\" value=\"0\"/>
    <property name=\"DecorationLayout\" type=\"string\" value=\"menu:minimize,maximize,close\"/>
  </property>
</channel>
THEME_EOF
        
        # Copy theme config to user
        cp /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml /home/ferret/.config/xfce4/xfconf/xfce-perchannel-xml/
        chown -R ferret:ferret /home/ferret/.config
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
    mkdir -p "$ROOT_DIR/boot/grub/themes/ferret"
    
    # Copy branding files
    if [[ -d "branding" ]]; then
        cp -r branding/* "$ROOT_DIR/usr/share/ferret-os/" || true
        
        # Copy logo to pixmaps for system use
        if [[ -f "branding/ferret-logo.svg" ]]; then
            cp "branding/ferret-logo.svg" "$ROOT_DIR/usr/share/pixmaps/ferret-os-logo.svg"
            cp "branding/ferret-logo.svg" "$ROOT_DIR/usr/share/backgrounds/ferret-wallpaper.svg"
        fi
        
        # Create Plymouth boot splash theme
        mkdir -p "$ROOT_DIR/usr/share/plymouth/themes/ferret"
        cat > "$ROOT_DIR/usr/share/plymouth/themes/ferret/ferret.plymouth" << 'PLYMOUTH_EOF'
[Plymouth Theme]
Name=Ferret OS
Description=Ferret OS Boot Splash
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/ferret
ScriptFile=/usr/share/plymouth/themes/ferret/ferret.script
PLYMOUTH_EOF

        # Create Plymouth script
        cat > "$ROOT_DIR/usr/share/plymouth/themes/ferret/ferret.script" << 'SCRIPT_EOF'
# Ferret OS Plymouth Boot Script

Window.SetBackgroundTopColor(0.16, 0.20, 0.25);
Window.SetBackgroundBottomColor(0.10, 0.12, 0.16);

# Load logo
if (Plymouth.GetMode() == "boot") {
    logo.image = Image("logo.png");
    logo.sprite = Sprite(logo.image);
    logo.opacity_angle = 0;
    
    # Center the logo
    logo.x = Window.GetWidth() / 2 - logo.image.GetWidth() / 2;
    logo.y = Window.GetHeight() / 2 - logo.image.GetHeight() / 2 - 50;
    logo.sprite.SetPosition(logo.x, logo.y, 10000);
    
    # Create text
    text.image = Image.Text("Ferret OS", 1, 1, 1, 1, "Ubuntu 16");
    text.sprite = Sprite(text.image);
    text.x = Window.GetWidth() / 2 - text.image.GetWidth() / 2;
    text.y = logo.y + logo.image.GetHeight() + 20;
    text.sprite.SetPosition(text.x, text.y, 10000);
    
    # Progress bar
    progress_box.image = Image("progress_box.png");
    progress_box.sprite = Sprite(progress_box.image);
    progress_box.x = Window.GetWidth() / 2 - progress_box.image.GetWidth() / 2;
    progress_box.y = Window.GetHeight() * 0.75;
    progress_box.sprite.SetPosition(progress_box.x, progress_box.y, 1000);
    
    progress_bar.original_image = Image("progress_bar.png");
    progress_bar.sprite = Sprite();
    progress_bar.x = Window.GetWidth() / 2 - progress_bar.original_image.GetWidth() / 2;
    progress_bar.y = Window.GetHeight() * 0.75;
    progress_bar.sprite.SetPosition(progress_bar.x, progress_bar.y, 2000);
}

fun progress_callback(duration, progress) {
    if (progress_bar.original_image) {
        new_progress_bar.image = progress_bar.original_image.Scale(progress_bar.original_image.GetWidth() * progress, progress_bar.original_image.GetHeight());
        progress_bar.sprite.SetImage(new_progress_bar.image);
    }
}

Plymouth.SetBootProgressFunction(progress_callback);

fun display_normal_callback() {
    global.status = "normal";
    if (logo.sprite) logo.sprite.SetOpacity(1);
    if (text.sprite) text.sprite.SetOpacity(1);
}

fun display_password_callback(prompt, bullets) {
    global.status = "password";
    if (logo.sprite) logo.sprite.SetOpacity(0.5);
    if (text.sprite) text.sprite.SetOpacity(0.5);
}

Plymouth.SetDisplayNormalFunction(display_normal_callback);
Plymouth.SetDisplayPasswordFunction(display_password_callback);
SCRIPT_EOF

        # Copy logo for Plymouth and convert if needed
        if [[ -f "branding/ferret-logo.svg" ]]; then
            cp "branding/ferret-logo.svg" "$ROOT_DIR/usr/share/plymouth/themes/ferret/logo.svg"
            # Convert to PNG for Plymouth if imagemagick is available
            if command -v convert &> /dev/null; then
                convert "branding/ferret-logo.svg" -resize 128x128 "$ROOT_DIR/usr/share/plymouth/themes/ferret/logo.png" 2>/dev/null || true
                # Create simple progress bar images
                convert -size 300x10 xc:"#3498db" "$ROOT_DIR/usr/share/plymouth/themes/ferret/progress_bar.png" 2>/dev/null || true
                convert -size 300x10 xc:"#2c3e50" "$ROOT_DIR/usr/share/plymouth/themes/ferret/progress_box.png" 2>/dev/null || true
            fi
        fi
    fi
    
    # Copy configuration files
    if [[ -d "config" ]]; then
        cp -r config/* "$ROOT_DIR/etc/ferret/" || true
        
        # Apply XFCE configuration
        if [[ -f "config/xfce-config.sh" ]]; then
            chmod +x "config/xfce-config.sh"
            chroot "$ROOT_DIR" /bin/bash -c "
                if [[ -f /etc/ferret/xfce-config.sh ]]; then
                    source /etc/ferret/xfce-config.sh
                    apply_system_xfce_config
                fi
            "
        fi
    fi
    
    # Install modern welcome application
    if [[ -f "packages/ferret-welcome.py" ]]; then
        cp "packages/ferret-welcome.py" "$ROOT_DIR/usr/bin/ferret-welcome"
        chmod +x "$ROOT_DIR/usr/bin/ferret-welcome"
        # Create desktop entry for welcome app
        cat > "$ROOT_DIR/etc/xdg/autostart/ferret-welcome.desktop" << 'WELCOME_EOF'
        [Desktop Entry]
        Type=Application
        Name=Ferret OS Welcome
        Exec=ferret-welcome
        Hidden=false
        NoDisplay=false
        X-GNOME-Autostart-enabled=true
        OnlyShowIn=XFCE;
        WELCOME_EOF

        # Install dependencies for welcome app
        chroot "$ROOT_DIR" /bin/bash -c "
            apt-get install -y python3-gi python3-gi-cairo gir1.2-gtk-3.0 gir1.2-webkit2-4.0
        "
    fi
    
    # Set OS release information - completely remove Debian references
    cat > "$ROOT_DIR/etc/os-release" << EOF
NAME="Ferret OS"
VERSION="$FERRET_VERSION ($FERRET_CODENAME)"
ID=ferret-os
ID_LIKE=""
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

    # Update issue files to show Ferret OS
    cat > "$ROOT_DIR/etc/issue" << EOF
Ferret OS $FERRET_VERSION \\n \\l

EOF

    cat > "$ROOT_DIR/etc/issue.net" << EOF
Ferret OS $FERRET_VERSION
EOF

    # Configure LightDM greeter with Ferret branding
    mkdir -p "$ROOT_DIR/etc/lightdm/lightdm-gtk-greeter.conf.d"
    cat > "$ROOT_DIR/etc/lightdm/lightdm-gtk-greeter.conf.d/10-ferret.conf" << EOF
[greeter]
background=/usr/share/backgrounds/ferret-wallpaper.svg
theme-name=Arc-Darker
icon-theme-name=Papirus-Dark
font-name=Inter 11
xft-antialias=true
xft-dpi=96
xft-hinting=true
xft-hintstyle=hintslight
xft-rgba=rgb
show-indicators=~host;~spacer;~clock;~spacer;~layout;~session;~power
user-background=false
hide-user-image=false
default-user-image=/usr/share/pixmaps/ferret-os-logo.svg
EOF
    
    # Install and configure Plymouth boot splash
    chroot "$ROOT_DIR" /bin/bash -c "
        apt-get install -y plymouth plymouth-themes
        
        # Set Ferret Plymouth theme
        plymouth-set-default-theme ferret
        update-initramfs -u || echo 'Plymouth update failed, continuing...'
    "
    
    success "Modern branding applied"
}

# Configure Calamares installer
configure_installer() {
    log "Configuring Calamares installer..."
    
    # Install Calamares
    chroot "$ROOT_DIR" /bin/bash -c "
        apt-get update
        apt-get install -y calamares calamares-settings-debian qml-module-qtquick2 qml-module-qtquick-controls
    "
    
    # Create Calamares configuration directories
    mkdir -p "$ROOT_DIR/etc/calamares"
    mkdir -p "$ROOT_DIR/etc/calamares/branding/ferret"
    mkdir -p "$ROOT_DIR/etc/calamares/modules"
    
    # Main Calamares settings
    cat > "$ROOT_DIR/etc/calamares/settings.conf" << 'CALAMARES_EOF'
modules-search: [ local, /lib/calamares/modules ]

instances:
- id:       ferret
  module:   users
  config:   users.conf

- id:       ferret
  module:   displaymanager
  config:   displaymanager.conf

sequence:
- show:
  - welcome
  - locale
  - keyboard
  - partition
  - users@ferret
  - summary
- exec:
  - partition
  - mount
  - unpackfs
  - machineid
  - fstab
  - locale
  - keyboard
  - localecfg
  - users@ferret
  - displaymanager@ferret
  - networkcfg
  - hwclock
  - services-systemd
  - bootloader
  - umount
- show:
  - finished

branding: ferret

prompt-install: true
dont-chroot: false
oem-setup: false
disable-cancel: false
disable-cancel-during-exec: false
hide-back-and-next-during-exec: false
quit-at-end: false
CALAMARES_EOF

    # Ferret OS branding for Calamares
    cat > "$ROOT_DIR/etc/calamares/branding/ferret/branding.desc" << 'BRANDING_EOF'
componentName:  ferret

strings:
    productName:         "Ferret OS"
    shortProductName:    "Ferret OS"
    version:             "1.0.0"
    shortVersion:        "1.0"
    versionedName:       "Ferret OS 1.0.0"
    shortVersionedName:  "Ferret OS 1.0"
    bootloaderEntryName: "Ferret OS"
    productUrl:          "https://ferret-os.org/"
    supportUrl:          "https://ferret-os.org/support/"
    knownIssuesUrl:      "https://ferret-os.org/issues/"
    releaseNotesUrl:     "https://ferret-os.org/releases/"
    donateUrl:           "https://ferret-os.org/donate/"

images:
    productLogo:         "logo.svg"
    productIcon:         "logo.svg"
    productWelcome:      "welcome.svg"

style:
   sidebarBackground:    "#2c3e50"
   sidebarText:          "#ffffff"
   sidebarTextSelect:    "#4f5b66"
   sidebarTextCurrent:   "#ffffff"

slideshow:               "show.qml"

slideshowAPI: 2
BRANDING_EOF

    # Copy logo files for Calamares
    if [[ -f "branding/ferret-logo.svg" ]]; then
        cp "branding/ferret-logo.svg" "$ROOT_DIR/etc/calamares/branding/ferret/logo.svg"
        cp "branding/ferret-logo.svg" "$ROOT_DIR/etc/calamares/branding/ferret/welcome.svg"
    fi
    
    # Copy slideshow
    if [[ -f "calamares_slideshow.qml" ]]; then
        cp "calamares_slideshow.qml" "$ROOT_DIR/etc/calamares/branding/ferret/show.qml"
    fi

    # Users module configuration
    cat > "$ROOT_DIR/etc/calamares/modules/users.conf" << 'USERS_EOF'
defaultGroups:
    - audio
    - video
    - network
    - storage
    - wheel
    - sudo

autologinGroup:  autologin
sudoersGroup:    wheel
setRootPassword: true
doAutologin:     false

passwordRequirements:
    minLength: 6
    maxLength: -1
    nonempty: true

allowWeakPasswords: false
allowWeakPasswordsDefault: false

userShell: /bin/bash

hostname:
  location: EtcFile
  writeHostsFile: true
  template: "ferret-${cpu}"
USERS_EOF

    # Display manager configuration
    cat > "$ROOT_DIR/etc/calamares/modules/displaymanager.conf" << 'DM_EOF'
displaymanagers:
  - lightdm

basicSetup: false

sysconfigSetup: false

defaultDesktopEnvironment:
    executable: "startxfce4"
    desktopFile: "xfce4-session"
DM_EOF

   mkdir -p "$ROOT_DIR/home/ferret/Desktop"

# Create desktop entry for installer
cat > "$ROOT_DIR/home/ferret/Desktop/install-ferret-os.desktop" << 'DESKTOP_EOF'
[Desktop Entry]
Type=Application
Version=1.0
Name=Install Ferret OS
GenericName=System Installer
Comment=Install Ferret OS to your computer
Exec=pkexec calamares
Icon=/usr/share/pixmaps/ferret-os-logo.svg
Terminal=false
StartupNotify=true
Categories=System;
Keywords=installer;calamares;install;
DESKTOP_EOF

chmod +x "$ROOT_DIR/home/ferret/Desktop/install-ferret-os.desktop"
chown ferret:ferret "$ROOT_DIR/home/ferret/Desktop/install-ferret-os.desktop"

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
        echo 'COMPRESS=xz' >> /etc/initramfs-tools/initramfs.conf
        
        # Add live boot components
        echo 'live-boot' >> /etc/initramfs-tools/modules
        echo 'overlay' >> /etc/initramfs-tools/modules
        echo 'squashfs' >> /etc/initramfs-tools/modules
        echo 'loop' >> /etc/initramfs-tools/modules
        
        # Configure Plymouth for boot splash
        echo 'FRAMEBUFFER=y' >> /etc/initramfs-tools/initramfs.conf
        
        # Configure GRUB for Ferret OS
        cat > /etc/default/grub << 'GRUB_CONFIG_EOF'
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR=\"Ferret OS\"
GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash plymouth.theme=ferret\"
GRUB_CMDLINE_LINUX=\"\"
GRUB_TERMINAL_OUTPUT=\"gfxterm\"
GRUB_GFXMODE=auto
GRUB_GFXPAYLOAD_LINUX=keep
GRUB_DISABLE_OS_PROBER=false
GRUB_THEME=/boot/grub/themes/ferret/theme.txt
GRUB_CONFIG_EOF
        
        # Update initramfs with Plymouth support
        update-initramfs -c -k all || echo 'Initramfs update failed, continuing...'
        
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
    
    # Copy Ferret logo for GRUB theme
    mkdir -p "$BUILD_DIR/iso/boot/grub/themes/ferret"
    if [[ -f "branding/ferret-logo.svg" ]]; then
        # Convert SVG to PNG for GRUB (requires imagemagick)
        if command -v convert &> /dev/null; then
            convert "branding/ferret-logo.svg" -resize 640x480 "$BUILD_DIR/iso/boot/grub/themes/ferret/background.png" 2>/dev/null || true
            convert "branding/ferret-logo.svg" -resize 128x128 "$BUILD_DIR/iso/boot/grub/themes/ferret/ferret-logo.png" 2>/dev/null || true
        fi
        # Also copy SVG as fallback
        cp "branding/ferret-logo.svg" "$BUILD_DIR/iso/boot/grub/themes/ferret/background.svg" 2>/dev/null || true
    fi
    
    # Create GRUB theme
    cat > "$BUILD_DIR/iso/boot/grub/themes/ferret/theme.txt" << 'GRUB_THEME_EOF'
desktop-image: "background.png"
title-color: "#ffffff"
title-font: "DejaVu Sans Bold 16"
title-text: "Ferret OS Boot Menu"

terminal-box: "terminal_box_*.png"
terminal-font: "DejaVu Sans Mono 12"

+ boot_menu {
  left = 10%
  top = 20%
  width = 80%
  height = 50%
  item_font = "DejaVu Sans 12"
  item_color = "#cccccc"
  selected_item_color = "#ffffff"
  selected_item_pixmap_style = "select_*.png"
  item_height = 32
  item_padding = 8
  item_spacing = 4
  icon_width = 24
  icon_height = 24
  item_icon_space = 8
}

+ label {
  top = 80%
  left = 0
  width = 100%
  height = 20
  text = "Ferret OS - Fast, Secure, Modern"
  align = "center"
  color = "#ffffff"
  font = "DejaVu Sans 12"
}
GRUB_THEME_EOF
    
    # GRUB configuration for BIOS boot with theme
    cat > "$BUILD_DIR/iso/boot/grub/grub.cfg" << 'EOF'
set timeout=10
set default=0

# Load theme if available
if loadfont /boot/grub/themes/ferret/DejaVu-Sans-12.pf2 ; then
  set theme=/boot/grub/themes/ferret/theme.txt
  export theme
fi

menuentry "Ferret OS Live" {
    linux /live/vmlinuz boot=live components quiet splash plymouth.theme=ferret
    initrd /live/initrd
}

menuentry "Ferret OS Live (Safe Mode)" {
    linux /live/vmlinuz boot=live components quiet splash nomodeset plymouth.theme=ferret
    initrd /live/initrd
}

menuentry "Ferret OS Live (Persistent)" {
    linux /live/vmlinuz boot=live components persistent quiet splash plymouth.theme=ferret
    initrd /live/initrd
}

menuentry "Memory Test (if available)" {
    linux16 /boot/memtest86+.bin
}
EOF
    
    # Enhanced Isolinux configuration for legacy systems
    cat > "$BUILD_DIR/iso/isolinux/isolinux.cfg" << 'EOF'
UI vesamenu.c32
MENU TITLE Ferret OS Boot Menu
MENU BACKGROUND ferret-splash.png
MENU COLOR border       30;44   #40ffffff #a0000000 std
MENU COLOR title        1;36;44 #9033ccff #a0000000 std
MENU COLOR sel          7;37;40 #e0ffffff #20ffffff all
MENU COLOR unsel        37;44   #50ffffff #a0000000 std
MENU COLOR help         37;40   #c0ffffff #a0000000 std
MENU COLOR timeout_msg  37;40   #80ffffff #00000000 std
MENU COLOR timeout      1;37;40 #c0ffffff #00000000 std
MENU COLOR msg07        37;40   #90ffffff #a0000000 std
MENU COLOR tabmsg       31;40   #30ffffff #00000000 std

TIMEOUT 100
DEFAULT live

LABEL live
    MENU LABEL ^Ferret OS Live
    KERNEL /live/vmlinuz
    APPEND initrd=/live/initrd boot=live components quiet splash plymouth.theme=ferret

LABEL safe
    MENU LABEL Ferret OS Live (^Safe Mode)
    KERNEL /live/vmlinuz
    APPEND initrd=/live/initrd boot=live components quiet splash nomodeset plymouth.theme=ferret

LABEL persistent
    MENU LABEL Ferret OS Live (^Persistent)
    KERNEL /live/vmlinuz
    APPEND initrd=/live/initrd boot=live components persistent quiet splash plymouth.theme=ferret
EOF
    
    # Copy splash image for isolinux
    if [[ -f "branding/ferret-logo.svg" ]] && command -v convert &> /dev/null; then
        convert "branding/ferret-logo.svg" -resize 640x480 "$BUILD_DIR/iso/isolinux/ferret-splash.png" 2>/dev/null || true
    fi
    
    # UEFI boot configuration with theme
    mkdir -p "$BUILD_DIR/iso/EFI/boot"
    
    cat > "$BUILD_DIR/iso/EFI/boot/grub.cfg" << 'EOF'
set timeout=10
set default=0

# Load theme if available
if loadfont /boot/grub/themes/ferret/DejaVu-Sans-12.pf2 ; then
  set theme=/boot/grub/themes/ferret/theme.txt
  export theme
fi

menuentry "Ferret OS Live (UEFI)" {
    linux /live/vmlinuz boot=live components quiet splash plymouth.theme=ferret
    initrd /live/initrd
}

menuentry "Ferret OS Live (UEFI Safe Mode)" {
    linux /live/vmlinuz boot=live components quiet splash nomodeset plymouth.theme=ferret
    initrd /live/initrd
}
EOF
    
    # Copy EFI boot files if available
    if [[ -f /usr/lib/grub/x86_64-efi/monolithic/grubx64.efi ]]; then
        cp /usr/lib/grub/x86_64-efi/monolithic/grubx64.efi "$BUILD_DIR/iso/EFI/boot/bootx64.efi"
    elif [[ -f /usr/lib/grub/x86_64-efi/grub.efi ]]; then
        cp /usr/lib/grub/x86_64-efi/grub.efi "$BUILD_DIR/iso/EFI/boot/bootx64.efi"
    fi
    
    success "GRUB configured with Ferret theme"
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
