# NVIDIA `.run` auto-rebuild no boot (Arch + Wayland)

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

## ⚙️ Instalação (recomendado)

A partir da raiz deste repositório:

```bash
chmod +x nvidia-auto-rebuild.sh
sudo ./nvidia-auto-rebuild.sh install
```

O script:

* cria os diretórios necessários
* copia os arquivos corretos para `/etc` e `/usr`
* ajusta permissões
* recarrega o systemd
* habilita o serviço

---

## 🔎 Verificar status

```bash
./nvidia-auto-rebuild.sh status
```

---

## ♻️ Reinstalar

```bash
sudo ./nvidia-auto-rebuild.sh reinstall
```

---

## ❌ Remover tudo

```bash
sudo ./nvidia-auto-rebuild.sh uninstall
```

---

## 🧪 Teste rápido (sem atualizar kernel)

Simule o que o hook faria:

```bash
sudo touch /var/lib/nvidia-reinstall-required
sudo reboot
```

Após entrar no sistema:

```bash
cat /var/log/nvidia-rebuild.log
```

---

## 🧠 Por que isso é necessário?

O instalador `.run` da NVIDIA **não pode ser executado com Wayland/Xorg ativos**.
Hooks do pacman rodam com o sistema gráfico em execução, portanto falham.

A única forma estável é recompilar o driver **no boot, antes do gráfico**.

---

## 📝 Requisitos

* Arch Linux
* Kernel `linux-lts`
* `linux-lts-headers`
* Driver NVIDIA instalado via `.run` com suporte a `--dkms`
* Caminho do `.run` ajustado em:

```
/usr/local/bin/nvidia-rebuild.sh
```

---

## ⬇️ Baixando e preparando o `.run`

Este projeto **não instala o driver**. Ele apenas automatiza a recompilação no boot.

1. Acesse:
   [https://download.nvidia.com/XFree86/Linux-x86_64/](https://download.nvidia.com/XFree86/Linux-x86_64/)

2. Baixe a versão compatível com sua GPU (ex.: `NVIDIA-Linux-x86_64-580.126.18.run`)

3. Mova para `/opt`:

```bash
sudo mkdir -p /opt/NVIDIA-Linux-x86_64-580.126.18
sudo mv NVIDIA-Linux-x86_64-580.126.18.run /opt/NVIDIA-Linux-x86_64-580.126.18/
sudo chmod +x /opt/NVIDIA-Linux-x86_64-580.126.18/NVIDIA-Linux-x86_64-580.126.18.run
```

4. Confirme que o caminho dentro do script corresponde a esse local:

```
/usr/local/bin/nvidia-rebuild.sh
```

> Ao atualizar a versão do driver, lembre-se de atualizar o caminho no script.

---

## 🧰 Instalação manual (modo antigo)

<details>
<summary>Clique para expandir</summary>

A partir da raiz do repositório:

```bash
sudo cp -r etc/ /
sudo cp -r usr/ /

sudo systemctl daemon-reload
sudo systemctl enable nvidia-rebuild.service
```

Verifique:

```bash
ls /etc/pacman.d/hooks/nvidia-rebuild.hook
ls /etc/systemd/system/nvidia-rebuild.service
ls /usr/local/bin/nvidia-rebuild.sh
```

</details>
