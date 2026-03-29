# NVIDIA `.run` auto‑rebuild no boot (Arch + Wayland)

Automatiza a reinstalação do driver proprietário da NVIDIA via `.run` no boot do Arch Linux, **antes** do ambiente gráfico iniciar — solução necessária para quem usa Wayland e não pode executar o instalador com o servidor gráfico ativo.

---

## 📦 O que isso faz

Quando `linux-lts` ou `linux-lts-headers` atualizam:

1. O hook do pacman marca que a NVIDIA precisa ser recompilada
2. No próximo boot, ainda no estágio inicial do systemd (`sysinit.target`)
3. O script roda **antes de qualquer coisa de vídeo existir**
4. O driver é recompilado via `.run --dkms`
5. O `mkinitcpio -P` é executado
6. O GNOME/Wayland sobe já com o módulo correto

Sem TTY. Sem tela preta. Sem reinstalar manualmente.

---

## ⚙️ Instalação

A partir da raiz deste repositório:

```bash
sudo cp -r etc/ /
sudo cp -r usr/ /

sudo systemctl daemon-reload
sudo systemctl enable nvidia-rebuild.service
```

---

## ✅ Verifique se os arquivos estão no lugar

```bash
ls /etc/pacman.d/hooks/nvidia-rebuild.hook
ls /etc/systemd/system/nvidia-rebuild.service
ls /usr/local/bin/nvidia-rebuild.sh
```

---

## 🧪 Teste rápido (sem atualizar kernel)

Simule o que o hook faria:

```bash
sudo touch /var/lib/nvidia-reinstall-required
sudo reboot
```

Durante o boot, o driver será recompilado automaticamente.

Após entrar no sistema, confira o log:

```bash
cat /var/log/nvidia-rebuild.log
```

Se não houver erros, está tudo funcionando corretamente.

---

## 🧠 Por que isso é necessário?

O instalador `.run` da NVIDIA **não pode ser executado com Wayland/Xorg ativos**.
Hooks do pacman rodam com o sistema gráfico em execução, portanto falham.

A única forma estável é recompilar o driver **no boot, antes do gráfico**, que é exatamente o que este projeto faz.

---

## 📝 Requisitos

* Arch Linux
* Kernel `linux-lts`
* `linux-lts-headers` instalados
* Driver NVIDIA instalado via `.run` com suporte a `--dkms`
* Caminho do `.run` ajustado em:

```
/usr/local/bin/nvidia-rebuild.sh
```

---

## ⬇️ Baixando e preparando o arquivo `.run`

Este projeto **não** instala o driver para você. Ele apenas automatiza a recompilação no boot.

Você precisa baixar manualmente o instalador oficial da NVIDIA e colocá‑lo no caminho esperado pelo script.

1. Acesse:

```
https://download.nvidia.com/XFree86/Linux-x86_64/
```

2. Baixe a versão do driver compatível com sua GPU (ex.: `NVIDIA-Linux-x86_64-580.126.18.run`).

3. Crie o diretório em `/opt` e mova o arquivo para lá:

```bash
sudo mkdir -p /opt/NVIDIA-Linux-x86_64-580.126.18
sudo mv NVIDIA-Linux-x86_64-580.126.18.run /opt/NVIDIA-Linux-x86_64-580.126.18/
```

4. Dê permissão de execução:

```bash
sudo chmod +x /opt/NVIDIA-Linux-x86_64-580.126.18/NVIDIA-Linux-x86_64-580.126.18.run
```

5. Confirme que o caminho no script corresponde exatamente a este local:

```
/usr/local/bin/nvidia-rebuild.sh
```

> Se você atualizar a versão do driver no futuro, **lembre-se de atualizar também o caminho dentro do script**.
