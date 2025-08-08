# Ferret OS

A modern, user-friendly Linux distribution built from scratch for developers, professionals, and general computing.

## 🎯 Project Overview

Ferret OS is a complete Linux-based operating system featuring:

- **Base**: Debian-based system with Linux 6.x LTS kernel
- **Desktop**: XFCE 4.18+ (lightweight, customizable)
- **Display**: Xorg with Wayland support
- **Init**: systemd
- **Package Management**: APT + Flatpak + AppImage support
- **Installer**: Calamares GUI installer
- **Security**: UFW firewall + AppArmor
- **Filesystem**: ext4 (default), Btrfs & LUKS encryption support

## 🏗️ Architecture

```
Ferret OS Stack:
├── Linux Kernel 6.x LTS
├── systemd (init system)
├── Debian base packages
├── XFCE Desktop Environment
├── Xorg Display Server
├── NetworkManager
├── PulseAudio/PipeWire
├── Calamares Installer
├── GNOME Software (App Store)
├── UFW + AppArmor (Security)
└── Custom Ferret Branding
```

## 🔧 Build Requirements

- Linux host system (Ubuntu 22.04+ recommended)
- 32GB+ free disk space
- 8GB+ RAM
- debootstrap, chroot, xorriso tools
- QEMU for testing

## 📁 Project Structure

```
ferret/
├── build/                  # Build scripts and automation
├── config/                 # System configuration files
├── branding/              # Ferret OS visual identity
├── packages/              # Custom packages and patches
├── installer/             # Calamares installer configuration
├── iso/                   # ISO building workspace
├── testing/               # VM and hardware testing
└── docs/                  # Documentation
```

## 🚀 Quick Start

```bash
# Clone and build
git clone <repository>
cd ferret
sudo ./build/build-ferret-os.sh

# Test in QEMU
./testing/test-iso.sh output/ferret-os-x.x.x.iso
```

## 📋 Features

### Desktop Environment
- [x] XFCE Desktop with custom Ferret theme
- [x] File Manager (Thunar)
- [x] Terminal Emulator (XFCE Terminal)
- [x] Web Browser (Firefox)
- [x] Text Editor (Mousepad + VS Code)
- [x] Settings Manager

### System Tools
- [x] Calamares GUI Installer
- [x] GNOME Software (App Store)
- [x] NetworkManager GUI
- [x] PulseAudio Volume Control
- [x] Bluetooth Manager
- [x] System Monitor

### Development Tools
- [x] GCC/G++ Compiler Suite
- [x] Python 3.x
- [x] Node.js & npm
- [x] Git
- [x] Docker support
- [x] VS Code (via Flatpak)

### Security
- [x] UFW Firewall (pre-configured)
- [x] AppArmor profiles
- [x] LUKS disk encryption support
- [x] Secure boot compatibility

## 🎨 Branding

- **Name**: Ferret OS
- **Mascot**: Stylized minimalist ferret
- **Colors**: Blue gradient (#2563EB → #1E40AF)
- **Font**: Inter (UI), JetBrains Mono (Terminal)

## 📦 Package Support

- **APT**: Native Debian packages
- **Flatpak**: Sandboxed applications
- **AppImage**: Portable applications
- **Snap**: Optional (can be enabled)

## 🔒 Security

- UFW firewall enabled by default
- AppArmor mandatory access control
- Automatic security updates
- Encrypted home directory option
- Secure boot support

## 🌐 Internationalization

- Full UTF-8 support
- Multi-language support
- RTL language support
- Timezone and locale configuration

## 📋 System Requirements

### Minimum
- 64-bit x86 processor
- 2GB RAM
- 20GB disk space
- VGA graphics

### Recommended
- Modern 64-bit processor
- 4GB+ RAM
- 40GB+ disk space
- Graphics card with hardware acceleration
- Internet connection for updates

## 🧪 Testing

- QEMU/KVM virtual machine testing
- VirtualBox compatibility
- UEFI and BIOS boot testing
- Hardware compatibility validation

## 📄 License

GPL v3.0 - See LICENSE file for details

## 🤝 Contributing

See CONTRIBUTING.md for development guidelines.

---

**Ferret OS** - Fast, Reliable, Modern Linux Distribution
