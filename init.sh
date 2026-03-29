#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-}"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Fontes do repo
HOOK_SRC="$REPO_DIR/etc/pacman.d/hooks/nvidia-rebuild.hook"
SERVICE_SRC="$REPO_DIR/etc/systemd/system/nvidia-rebuild.service"
SCRIPT_SRC="$REPO_DIR/usr/local/bin/nvidia-rebuild.sh"

# Destinos no sistema
HOOK_DST="/etc/pacman.d/hooks/nvidia-rebuild.hook"
SERVICE_DST="/etc/systemd/system/nvidia-rebuild.service"
SCRIPT_DST="/usr/local/bin/nvidia-rebuild.sh"

# Config download NVIDIA
BASE_DIR="/opt"
URL="https://download.nvidia.com/XFree86/Linux-x86_64/"
VERSION="NVIDIA-Linux-x86_64-580.126.18.run"

RUN_DIR="$BASE_DIR/${VERSION%.run}"
RUN_PATH="$RUN_DIR/$VERSION"

require_root() {
  [[ $EUID -ne 0 ]] && {
    echo "Execute como root: sudo ./init.sh <comando>"
    exit 1
  }
}

download_run() {
  echo "==> Baixando driver NVIDIA oficial..."

  mkdir -p "$RUN_DIR"

  if [[ ! -f "$RUN_PATH" ]]; then
    curl -L "$URL/$VERSION" -o "$RUN_PATH"
  fi

  chmod +x "$RUN_PATH"
}

patch_rebuild_script() {
  echo "==> Ajustando caminho do .run no nvidia-rebuild.sh"
  sed -i "s|^NVIDIA_RUN=.*|NVIDIA_RUN=\"$RUN_PATH\"|" "$SCRIPT_DST"
}

install_all() {
  echo "==> Instalando arquivos do projeto..."

  mkdir -p /etc/pacman.d/hooks
  mkdir -p /etc/systemd/system
  mkdir -p /usr/local/bin

  cp -f "$HOOK_SRC" "$HOOK_DST"
  cp -f "$SERVICE_SRC" "$SERVICE_DST"
  cp -f "$SCRIPT_SRC" "$SCRIPT_DST"

  chmod +x "$SCRIPT_DST"

  download_run
  patch_rebuild_script

  systemctl daemon-reload
  systemctl enable nvidia-rebuild.service

  echo "Instalação concluída!"
}

uninstall_all() {
  echo "==> Removendo tudo..."

  systemctl disable nvidia-rebuild.service 2>/dev/null || true

  rm -f "$HOOK_DST"
  rm -f "$SERVICE_DST"
  rm -f "$SCRIPT_DST"

  rm -rf "$RUN_DIR"

  systemctl daemon-reload

  echo "Remoção completa!"
}

status_all() {
  echo "==> Status:"
  [[ -f "$HOOK_DST" ]] && echo "Hook OK" || echo "Hook ausente"
  [[ -f "$SERVICE_DST" ]] && echo "Service OK" || echo "Service ausente"
  [[ -x "$SCRIPT_DST" ]] && echo "Script OK" || echo "Script ausente"
  [[ -f "$RUN_PATH" ]] && echo ".run OK ($RUN_PATH)" || echo ".run ausente"
}

case "$ACTION" in
  install)
    require_root
    install_all
    ;;
  uninstall)
    require_root
    uninstall_all
    ;;
  status)
    status_all
    ;;
  *)
    echo "Uso: sudo ./init.sh {install|uninstall|status}"
    ;;
esac