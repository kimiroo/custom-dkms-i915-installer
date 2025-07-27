#!/bin/bash

echo "[CHECK] Kernel: $(uname -r)"
echo

# Check i915 module
echo "[CHECK] i915 kernel module"
lsmod | grep i915 || echo "[WARN] i915 module is not loaded."
echo

# Check sriov_numvfs
VF_PATH="/sys/bus/pci/devices/0000:00:02.0/sriov_numvfs"
if [ -f "$VF_PATH" ]; then
    echo "[CHECK] sriov_numvfs: $(cat $VF_PATH)"
else
    echo "[ERROR] sriov_numvfs path not found: $VF_PATH"
fi
echo

# Check enable_guc
GUC_PATH="/sys/module/i915/parameters/enable_guc"
if [ -f "$GUC_PATH" ]; then
    echo "[CHECK] enable_guc: $(cat $GUC_PATH)"
else
    echo "[ERROR] enable_guc parameter not found."
fi
echo

# Check VFs presence
echo "[CHECK] VFs detected on PCI bus:"
lspci | grep "Virtual Function"
echo

# Check for sysfs.conf presence
echo "[CHECK] /etc/sysfs.conf content:"
if [ -f /etc/sysfs.conf ]; then
    cat /etc/sysfs.conf
else
    echo "[WARN] /etc/sysfs.conf not found."
fi

echo
echo "[INFO] Post-reboot check complete."
