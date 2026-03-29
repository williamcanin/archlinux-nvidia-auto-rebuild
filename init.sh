#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-}"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

HOOK_SRC="$REPO_DIR/etc/pacman.d/hooks/nvidia-rebuild.hook"
SERVICE_SRC="$REPO_DIR/etc/systemd/system/nvidia-rebuild.service"
SCRIPT_SRC="$REPO_DIR/usr/local/bin/nvidia-rebuild.sh"

HOOK_DST="/etc/pacman.d/hooks/nvidia-rebuild.hook"
SERVICE_DST="/etc/systemd/system/nvidia-rebuild.service"
SCRIPT_DST="/usr/local/bin/nvidia-rebuild.sh"

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "ERRO: execute como root (sudo ./nvidia-auto-rebuild.sh <comando>)"
    exit 1
  fi
}

install_files() {
  echo "==> Instalando NVIDIA auto-rebuild..."

  mkdir -p /etc/pacman.d/hooks
  mkdir -p /etc/systemd/system
  mkdir -p /usr/local/bin

  cp -f "$HOOK_SRC" "$HOOK_DST"
  cp -f "$SERVICE_SRC" "$SERVICE_DST"
  cp -f "$SCRIPT_SRC" "$SCRIPT_DST"

  chmod +x "$SCRIPT_DST"

  systemctl daemon-reload
  systemctl enable nvidia-rebuild.service

  echo
  echo "Instalação concluída!"
}

uninstall_files() {
  echo "==> Removendo NVIDIA auto-rebuild..."

  systemctl disable nvidia-rebuild.service 2>/dev/null || true
  rm -f "$HOOK_DST"
  rm -f "$SERVICE_DST"
  rm -f "$SCRIPT_DST"

  systemctl daemon-reload

  echo
  echo "Remoção concluída!"
}

status_check() {
  echo "==> Status da instalação"
  echo

  [[ -f "$HOOK_DST" ]] && echo "✔ Hook instalado" || echo "✘ Hook ausente"
  [[ -f "$SERVICE_DST" ]] && echo "✔ Service instalado" || echo "✘ Service ausente"
  [[ -x "$SCRIPT_DST" ]] && echo "✔ Script instalado" || echo "✘ Script ausente"

  echo
  systemctl is-enabled nvidia-rebuild.service &>/dev/null \
    && echo "✔ Service habilitado" \
    || echo "✘ Service não habilitado"
}

reinstall_files() {
  uninstall_files
  install_files
}

usage() {
  echo "Uso:"
  echo "  sudo ./nvidia-auto-rebuild.sh install"
  echo "  sudo ./nvidia-auto-rebuild.sh uninstall"
  echo "  sudo ./nvidia-auto-rebuild.sh reinstall"
  echo "  sudo ./nvidia-auto-rebuild.sh status"
  exit 1
}

case "$ACTION" in
  install)
    require_root
    install_files
    ;;
  uninstall)
    require_root
    uninstall_files
    ;;
  reinstall)
    require_root
    reinstall_files
    ;;
  status)
    status_check
    ;;
  *)
    usage
    ;;
esac
