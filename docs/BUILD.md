# Building Ferret OS

This document provides comprehensive instructions for building Ferret OS from source.

## Prerequisites

### Host System Requirements

**Recommended Host Operating System:**
- Ubuntu 22.04 LTS or newer
- Debian 12 (Bookworm) or newer
- Any modern Linux distribution with the required tools

**Hardware Requirements:**
- 64-bit x86 processor (AMD64/Intel 64)
- Minimum 8GB RAM (16GB+ recommended)
- 50GB+ free disk space
- Internet connection for downloading packages

**Required Software:**
```bash
# Install build dependencies on Ubuntu/Debian
sudo apt update
sudo apt install -y \
    debootstrap \
    squashfs-tools \
    xorriso \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    dosfstools \
    git \
    curl \
    wget \
    qemu-system-x86 \
    qemu-utils \
    ovmf
```

## Build Process

### 1. Clone the Repository

```bash
git clone https://github.com/ferret-os/ferret.git
cd ferret
```

### 2. Prepare Build Environment

```bash
# Make build script executable
chmod +x build/build-ferret-os.sh
chmod +x testing/test-iso.sh

# Ensure you have sudo privileges
sudo -v
```

### 3. Build Ferret OS

```bash
# Full build (requires sudo)
sudo ./build/build-ferret-os.sh
```

The build process includes:
1. **Bootstrap**: Create Debian base system using debootstrap
2. **Package Installation**: Install essential and desktop packages
3. **Configuration**: Configure system settings, users, and services
4. **Branding**: Apply Ferret OS visual identity
5. **SquashFS Creation**: Create compressed filesystem
6. **ISO Generation**: Create bootable ISO with GRUB

### 4. Build Output

After successful build, you'll find:
```
ferret/iso/output/
├── ferret-os-1.0.0-amd64.iso        # Bootable ISO
└── ferret-os-1.0.0-amd64.iso.sha256 # Checksum file
```

## Build Configuration

### Environment Variables

You can customize the build by setting environment variables:

```bash
# Set custom version
export FERRET_VERSION="1.1.0"
export FERRET_CODENAME="Swift"

# Set custom architecture (default: amd64)
export ARCH="amd64"

# Set custom Debian release (default: bookworm)
export DEBIAN_RELEASE="bookworm"

# Run build
sudo -E ./build/build-ferret-os.sh
```

### Custom Package Lists

Edit package lists in `build/build-ferret-os.sh`:

```bash
# Essential packages
essential_packages=(
    "linux-image-$ARCH"
    "systemd"
    # Add your packages here
)

# Desktop packages
desktop_packages=(
    "xfce4"
    "firefox-esr"
    # Add your packages here
)
```

## Advanced Customization

### Adding Custom Packages

1. **Pre-built packages**: Add to package lists in build script
2. **Custom .deb packages**: Place in `packages/` directory
3. **Source compilation**: Add build steps to `build/build-ferret-os.sh`

### Modifying Desktop Environment

Edit XFCE configuration in `config/xfce-config.sh`:

```bash
# Customize themes, panels, shortcuts
configure_xfce_theme() {
    # Your customizations here
}
```

### Custom Branding

Replace files in `branding/` directory:
- `ferret-logo.svg` - Main logo
- `ferret-icon.svg` - Application icon
- `ferret-wallpaper.png` - Desktop wallpaper
- Theme files and colors

### Installer Configuration

Modify Calamares settings in `installer/` directory:
- `settings.conf` - Main installer configuration
- `modules/` - Individual module settings
- `branding/` - Installer branding

## Testing

### Automated Testing

```bash
# Test the built ISO
./testing/test-iso.sh iso/output/ferret-os-1.0.0-amd64.iso
```

This runs:
- ISO integrity check
- BIOS boot test
- UEFI boot test (if OVMF available)
- Memory configuration tests

### Manual Testing

1. **VirtualBox Testing**:
   ```bash
   # Create new VM
   VBoxManage createvm --name "Ferret-Test" --register
   VBoxManage modifyvm "Ferret-Test" --memory 4096 --cpus 2 --vram 128
   VBoxManage storagectl "Ferret-Test" --name "IDE" --add ide
   VBoxManage storageattach "Ferret-Test" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium ferret-os-1.0.0-amd64.iso
   VBoxManage startvm "Ferret-Test"
   ```

2. **Physical Hardware Testing**:
   - Create bootable USB: `dd if=ferret-os-1.0.0-amd64.iso of=/dev/sdX bs=4M status=progress`
   - Test on various hardware configurations
   - Verify UEFI and BIOS boot modes

## Troubleshooting

### Common Issues

**Build fails with "No space left on device"**:
- Ensure 50GB+ free space
- Check `/tmp` space (build uses temporary files)

**Package installation fails**:
- Check internet connection
- Verify Debian repositories are accessible
- Try different mirror in `build/build-ferret-os.sh`

**ISO won't boot**:
- Verify ISO integrity with SHA256 checksum
- Check GRUB configuration in build script
- Test with different virtualization software

**Permission errors**:
- Ensure script runs with sudo
- Check file ownership in build directories

### Debug Mode

Enable debug output:
```bash
# Run with verbose output
sudo bash -x ./build/build-ferret-os.sh
```

### Clean Build

Remove build artifacts:
```bash
sudo rm -rf iso/build iso/rootfs iso/output
```

## Build Script Details

### Directory Structure During Build

```
ferret/iso/
├── build/              # Temporary build files
│   ├── live/           # SquashFS creation
│   └── iso/            # ISO directory structure
├── rootfs/             # Chroot environment (Debian system)
└── output/             # Final ISO output
```

### Build Phases

1. **Bootstrap** (`bootstrap_system`):
   - Uses debootstrap to create minimal Debian system
   - Sets up basic directory structure

2. **Package Installation** (`install_packages`):
   - Mounts proc, sys, dev for chroot
   - Installs kernel, desktop, and application packages
   - Configures package sources

3. **System Configuration** (`configure_system`):
   - Sets hostname, locale, timezone
   - Creates live user account
   - Configures automatic login

4. **Branding** (`apply_branding`):
   - Copies custom themes and logos
   - Sets OS identification files
   - Applies visual customizations

5. **Security Setup** (`configure_security`):
   - Enables UFW firewall
   - Configures AppArmor
   - Sets up security policies

6. **SquashFS Creation** (`create_squashfs`):
   - Compresses root filesystem
   - Uses XZ compression for size optimization

7. **ISO Assembly** (`create_iso`):
   - Creates ISO directory structure
   - Configures GRUB for BIOS and UEFI
   - Generates bootable ISO with xorriso

## Performance Optimization

### Build Performance

- **Use SSD**: Significantly faster I/O operations
- **More RAM**: Reduces swap usage during compilation
- **Parallel Jobs**: Increase `make -j` parallelism
- **Local Mirror**: Use local Debian mirror for faster downloads

### Runtime Performance

- **Kernel Selection**: Use optimized kernel configs
- **Service Optimization**: Disable unnecessary services
- **Memory Management**: Tune swappiness and cache settings
- **Filesystem**: Consider Btrfs with compression

## Security Considerations

### Build Security

- **Verify Sources**: Check package authenticity
- **Secure Downloads**: Use HTTPS for all downloads
- **Signature Verification**: Verify GPG signatures when possible
- **Reproducible Builds**: Ensure deterministic build process

### Runtime Security

- **Default Firewall**: UFW enabled by default
- **Access Control**: AppArmor profiles active
- **Update Strategy**: Automatic security updates enabled
- **User Privileges**: Non-root user by default

## Contributing to Build System

### Code Style

- Use bash best practices
- Include error handling (`set -e`)
- Add descriptive comments
- Use consistent indentation

### Testing Changes

```bash
# Test individual components
sudo ./build/test-bootstrap.sh
sudo ./build/test-packages.sh
sudo ./build/test-config.sh
```

### Submitting Changes

1. Test build thoroughly
2. Verify ISO boots and installs correctly
3. Update documentation as needed
4. Submit pull request with detailed description

---

For additional help, visit:
- [Ferret OS Documentation](https://docs.ferret-os.org)
- [Community Forum](https://forum.ferret-os.org)
- [GitHub Issues](https://github.com/ferret-os/ferret/issues)
