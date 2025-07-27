# custom-dkms-i915-installer

Installs a custom i915 driver as a DKMS module with SR-IOV support for Intel Alder Lake graphics.

This installer automates the process of building and installing the [i915-sriov-dkms](https://github.com/strongtz/i915-sriov-dkms) module.

### Overview

- Provides SR-IOV support for Intel i915 graphics driver on Proxmox VE 8.2+ and compatible kernels.
- Automates DKMS module installation and configuration.
- Applies necessary kernel parameters for SR-IOV and GuC firmware.
- Configures GRUB and sysfs settings accordingly.

### Usage

This project is based on the instructions from [Derek Seaman's blog](https://www.derekseaman.com/2024/07/proxmox-ve-8-2-windows-11-vgpu-vt-d-passthrough-with-intel-alder-lake.html).

The installer script handles:

- Installing dependencies and kernel headers.
- Cloning and updating the i915-sriov-dkms repository.
- Registering and building the DKMS module for the current kernel.
- Updating kernel boot parameters.
- Configuring initramfs and sysfs.

### Requirements

- Proxmox VE 8.2 or newer with Linux kernel 6.8.x or compatible.
- Root privileges to run the installer.
- Network access to clone the git repository.

### Installation

Run the provided installation script:

```bash
chmod +x ./install.sh
./install.sh
```

or

```bash
curl -sSL https://raw.githubusercontent.com/kimiroo/custom-dkms-i915-installer/refs/heads/main/install.sh | bash
```

### Verification

Use the provided `check.sh` script to verify proper installation:

```bash
chmod +x ./check.sh
./check.sh
```

or

```bash
curl -sSL https://raw.githubusercontent.com/kimiroo/custom-dkms-i915-installer/refs/heads/main/check.sh | bash
```

### License
This project uses the MIT License. See LICENSE file for details.