#!/bin/bash

CURRENT_KERNEL=$(uname -r)
DKMS_STATUS=$(dkms status)
PKG_KERNEL=$(echo "$DKMS_STATUS" | cut -d',' -f2 | xargs | head -n1)
PCI_BUS=$(lspci | grep VGA | head -n1 | awk '{print $1}')

# Kernel version
echo "[CHECK] Kernel: $CURRENT_KERNEL"

# DKMS Status
echo "[CHECK] DKMS Status: $DKMS_STATUS"

# Compare kernel version with package's kernel version
if [ "$CURRENT_KERNEL" != "$PKG_KERNEL" ]; then
    echo "[WARNING] Kernel version mismatch: Kernel: '$CURRENT_KERNEL', Package: '$PKG_KERNEL'" >&2
fi

# Module file path
MODULE_PATH=$(modinfo i915 2>/dev/null | grep filename | awk '{print $2}')
if [ -z "$MODULE_PATH" ]; then
    echo "[ERROR] Failed to retrieve i915 module path." >&2
else
    echo "[CHECK] Module File Path: $MODULE_PATH"
fi

# PCI Bus Number
echo "[INFO]  Detected PCI Bus Number: $PCI_BUS"
echo

# Check sriov_numvfs
VF_PATH="/sys/bus/pci/devices/0000:$PCI_BUS/sriov_numvfs"
if [ -f "$VF_PATH" ]; then
    echo "[CHECK] sriov_numvfs: $(cat $VF_PATH)"
else
    echo "[ERROR] sriov_numvfs path not found: $VF_PATH" >&2
fi

# Check enable_guc
GUC_PATH="/sys/module/i915/parameters/enable_guc"
if [ -f "$GUC_PATH" ]; then
    echo "[CHECK] enable_guc: $(cat $GUC_PATH)"
else
    echo "[ERROR] enable_guc parameter not found."
fi

# Check PCI VGAs
echo
echo "[CHECK] Detected PCI VGAs:"
lspci | grep "VGA"
echo

# Check dmesg i915 output
echo "[CHECK] dmesg - i915 drm initialization:"
dmesg | grep "i915" | grep "\[drm\]" | grep "Initialized"
echo

DMESG_VFS=$(dmesg | grep "i915" | grep "Enabled" | grep "VFs")
if [ -n "$DMESG_VFS" ]; then
    echo "[CHECK] dmesg - VFs enabled:"
    echo "$DMESG_VFS"
else
    echo "[ERROR] No VFs enabled."
fi
echo

# Check for sysfs.conf presence
echo "[CHECK] /etc/sysfs.conf content:"
if [ -f /etc/sysfs.conf ]; then
    cat /etc/sysfs.conf
else
    echo "[ERROR] /etc/sysfs.conf not found."
fi

echo
echo "[INFO]  Post-reboot check complete."