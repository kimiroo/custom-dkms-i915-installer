# custom-dkms-i915-installer

Installs a custom i915 driver as a DKMS module with SR-IOV support for Intel Alder Lake graphics.

This installer is **specifically designed for Proxmox VE environments** and automates the process of building and installing the [i915-sriov-dkms](https://github.com/strongtz/i915-sriov-dkms) module.

### Overview

- Provides SR-IOV support for **Intel i915 graphics driver on Proxmox VE 8.2+ and compatible kernels.**\
  This allows you to efficiently share a single physical Intel integrated GPU across multiple virtual machines (VMs).
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

- Proxmox VE 8.2 or newer
- Linux kernel version supported by [i915-sriov-dkms](https://github.com/strongtz/i915-sriov-dkms)\
  (6.8-6.15(-rc5) as of Jul 27, 2025)
- Root privileges to run the installer.
- Network access to clone the git repository.

### Installation

1. Run the provided installation script:

```bash
./install.sh
```

or

```bash
curl -sSL https://raw.githubusercontent.com/kimiroo/custom-dkms-i915-installer/refs/heads/main/install.sh | bash
```
2. Reboot the machine to apply dkms module.

### Verification

Use the provided `check.sh` script to verify proper installation:

```bash
./check.sh
```

or

```bash
curl -sSL https://raw.githubusercontent.com/kimiroo/custom-dkms-i915-installer/refs/heads/main/check.sh | bash
```

\
\
Output of `check.sh` should look something like this:
```bash
[CHECK] Kernel: 6.8.12-11-pve
[CHECK] DKMS Status: i915-sriov-dkms/2025.07.22, 6.8.12-11-pve, x86_64: installed
[CHECK] Module File Path: /lib/modules/6.8.12-11-pve/updates/dkms/i915.ko
[INFO]  Detected PCI Bus Number: 00:02.0

[CHECK] sriov_numvfs: 7
[CHECK] enable_guc: 3

[CHECK] Detected PCI VGAs:
00:02.0 VGA compatible controller: Intel Corporation Alder Lake-N [UHD Graphics]
00:02.1 VGA compatible controller: Intel Corporation Alder Lake-N [UHD Graphics]
00:02.2 VGA compatible controller: Intel Corporation Alder Lake-N [UHD Graphics]
00:02.3 VGA compatible controller: Intel Corporation Alder Lake-N [UHD Graphics]
00:02.4 VGA compatible controller: Intel Corporation Alder Lake-N [UHD Graphics]
00:02.5 VGA compatible controller: Intel Corporation Alder Lake-N [UHD Graphics]
00:02.6 VGA compatible controller: Intel Corporation Alder Lake-N [UHD Graphics]
00:02.7 VGA compatible controller: Intel Corporation Alder Lake-N [UHD Graphics]

[CHECK] dmesg - i915 drm initialization:
[    4.643352] [drm] Initialized i915 1.6.0 20230929 for 0000:00:02.0 on minor 0
[    5.215705] [drm] Initialized i915 1.6.0 20230929 for 0000:00:02.1 on minor 1
[    5.221342] [drm] Initialized i915 1.6.0 20230929 for 0000:00:02.2 on minor 2
[    5.227642] [drm] Initialized i915 1.6.0 20230929 for 0000:00:02.3 on minor 3
[    5.233499] [drm] Initialized i915 1.6.0 20230929 for 0000:00:02.4 on minor 4
[    5.238482] [drm] Initialized i915 1.6.0 20230929 for 0000:00:02.5 on minor 5
[    5.242936] [drm] Initialized i915 1.6.0 20230929 for 0000:00:02.6 on minor 6
[    5.247418] [drm] Initialized i915 1.6.0 20230929 for 0000:00:02.7 on minor 7

[CHECK] dmesg - VFs enabled:
[    5.247604] i915 0000:00:02.0: Enabled 7 VFs

[CHECK] /etc/sysfs.conf content:
devices/pci0000:00/0000:00:02.0/sriov_numvfs = 7

[INFO]  Post-reboot check complete.
```

\
\
Following is a example of failed install:
```bash
[CHECK] Kernel: 6.8.12-13-pve
[CHECK] DKMS Status: i915-sriov-dkms/2025.07.22, 6.8.12-11-pve, x86_64: installed
[WARNING] Kernel version mismatch: Kernel: '6.8.12-13-pve', Package: '6.8.12-11-pve'
[CHECK] Module File Path: /lib/modules/6.8.12-13-pve/kernel/drivers/gpu/drm/i915/i915.ko
[INFO]  Detected PCI Bus Number: 00:02.0

[CHECK] sriov_numvfs: 0
[CHECK] enable_guc: 3

[CHECK] Detected PCI VGAs:
00:02.0 VGA compatible controller: Intel Corporation Alder Lake-N [UHD Graphics]

[CHECK] dmesg - i915 drm initialization:
[    4.062642] [drm] Initialized i915 1.6.0 20230929 for 0000:00:02.0 on minor 0

[ERROR] No VFs enabled.

[CHECK] /etc/sysfs.conf content:
devices/pci0000:00/0000:00:02.0/sriov_numvfs = 7

[INFO]  Post-reboot check complete.
```

This is caused by script installing the latest Linux kernel while installing dkms module for currently installed kernel version:

1. System has Linux kernel 6.8.12-11-pve.
2. Script installs latest Linux kernel 6.8.12-13-pve.
3. Script builds and installs dkms module for 6.8.12-11-pve, since system still uses old version(6.8.12-11-pve).
4. System reboots and now uses new 6.8.12-13-pve kernel.
5. Kernel version mismatch occurs and system fails to load dkms module.

In this case, re-running the install script to build and install new dkms module built for newly installed kernel will fix the issue.

### License
This project uses the MIT License. See LICENSE file for details.
