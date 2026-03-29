#!/bin/bash
set -e

FLAG="/var/lib/nvidia-reinstall-required"
LOG="/var/log/nvidia-rebuild.log"
DRIVER="/opt/NVIDIA-Linux-x86_64-580.126.18/NVIDIA-Linux-x86_64-580.126.18.run"

# Só roda se o hook marcou
[ -f "$FLAG" ] || exit 0

echo "==== NVIDIA REBUILD $(date) ====" >> "$LOG"

# Garante que nada da nvidia está carregado (segurança)
modprobe -r nvidia_drm nvidia_modeset nvidia || true

echo "-> Instalando driver..." >> "$LOG"
$DRIVER -s --dkms --no-questions >> "$LOG" 2>&1

echo "-> Recriando initramfs..." >> "$LOG"
mkinitcpio -P >> "$LOG" 2>&1

rm -f "$FLAG"

echo "==== NVIDIA OK ====" >> "$LOG"