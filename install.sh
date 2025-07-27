#!/bin/bash

set -e  # Stop on any error

echo "[INFO] Installing required packages..."
apt-get update
apt-get install -y git sysfsutils dkms mokutil pve-headers-$(uname -r) build-essential

echo "[INFO] Removing old DKMS modules and kernel objects..."
rm -rf /usr/src/i915-sriov-dkms-*
rm -rf /var/lib/dkms/i915-sriov-dkms
rm -rf ~/i915-sriov-dkms*

find /lib/modules -regex ".*/updates/dkms/i915.ko" -delete

cd ~

REPO_DIR="$HOME/i915-sriov-dkms"
if [ -d "$REPO_DIR" ]; then
    echo "[INFO] Repository already exists. Pulling latest changes..."
    cd "$REPO_DIR"
    git reset --hard HEAD
    git pull --rebase
else
    echo "[INFO] Cloning i915-sriov-dkms repository..."
    git clone https://github.com/strongtz/i915-sriov-dkms.git
    cd i915-sriov-dkms
fi

echo "[INFO] Adding DKMS module..."
dkms add .

echo "[INFO] Building DKMS module for kernel: $(uname -r)"
VERSION=$(dkms status -m i915-sriov-dkms | cut -d':' -f1)
dkms install -m "$VERSION" -k "$(uname -r)" --force

echo "[INFO] DKMS installation complete. Status:"
dkms status

echo "[INFO] Setting GRUB to update removable EFI bootloader..."
echo 'grub-efi-amd64 grub2/force_efi_extra_removable boolean true' | debconf-set-selections -v -u

echo "[INFO] Reinstalling grub-efi-amd64 package..."
sudo apt install --reinstall -y grub-efi-amd64

echo "[INFO] Updating initramfs..."
update-initramfs -u -k all

echo "[INFO] Backing up and modifying /etc/default/grub..."
cp -a /etc/default/grub{,.bak}
GRUB_LINE='GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt i915.enable_guc=3 i915.max_vfs=7"'
sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT/c\\$GRUB_LINE" /etc/default/grub
update-grub

CMDLINE_FILE="/etc/kernel/cmdline"
CMDLINE_ARGS="intel_iommu=on iommu=pt i915.enable_guc=3 i915.max_vfs=7"

echo "[INFO] Checking /etc/kernel/cmdline..."
if [ ! -f "$CMDLINE_FILE" ]; then
    echo "[INFO] Creating $CMDLINE_FILE..."
    echo "$CMDLINE_ARGS" > "$CMDLINE_FILE"
else
    if ! grep -q "i915.enable_guc=3" "$CMDLINE_FILE"; then
        echo "[INFO] Appending required parameters to $CMDLINE_FILE..."
        echo -n " " >> "$CMDLINE_FILE"
        echo -n "$CMDLINE_ARGS" >> "$CMDLINE_FILE"
        echo >> "$CMDLINE_FILE"
    else
        echo "[INFO] Required parameters already exist in $CMDLINE_FILE."
    fi
fi

echo "[INFO] Rebuilding initramfs..."
update-initramfs -u -k all

echo "[INFO] Configuring sysfs for VF enablement..."
echo "devices/pci0000:00/0000:00:02.0/sriov_numvfs = 7" > /etc/sysfs.conf

echo "[INFO] Setup complete. Please reboot the system."
