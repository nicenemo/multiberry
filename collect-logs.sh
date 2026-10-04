#!/usr/bin/env bash
# Collect system diagnostics for sudden crash analysis

OUT_FILE="debug_log.txt"
echo "=== SYSTEM DIAGNOSTICS LOG - $(date) ===" > "$OUT_FILE"

echo -e "\n------------------ 1. HARDWARE SUMMARY ------------------" >> "$OUT_FILE"
inxi -Fz 2>/dev/null || lscpu | grep "Model name" >> "$OUT_FILE"
lspci -k | grep -A 3 -i "vga\|3d" >> "$OUT_FILE"

echo -e "\n------------------ 2. PREVIOUS CRASH JOURNALS (-1 boot) ------------------" >> "$OUT_FILE"
echo "--- Last 100 lines of previous boot log ---" >> "$OUT_FILE"
journalctl -b -1 -n 100 --no-pager >> "$OUT_FILE" 2>&1

echo -e "\n------------------ 3. KERNEL ERRORS & PANICS ------------------" >> "$OUT_FILE"
journalctl -b -1 -p 0..3 --no-pager >> "$OUT_FILE" 2>&1 || dmesg -T -l err,crit,alert,emerg >> "$OUT_FILE" 2>&1

echo -e "\n------------------ 4. NVIDIA DRIVER & HARDWARE STATUS ------------------" >> "$OUT_FILE"
nvidia-smi >> "$OUT_FILE" 2>&1

echo -e "\n------------------ 5. MCE / HARDWARE ERROR CHECK ------------------" >> "$OUT_FILE"
journalctl -b -1 | grep -i -E "mce|hardware error|pcie|nvme|mce:" >> "$OUT_FILE" 2>&1

echo -e "\n------------------ 6. SYSTEM THERMALS & SENSORS ------------------" >> "$OUT_FILE"
sensors >> "$OUT_FILE" 2>&1

echo -e "\nLog generated successfully at $OUT_FILE"
