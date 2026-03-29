# NVIDIA `.run` auto-rebuild no boot (Arch + Wayland)

![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793D1?logo=arch-linux\&logoColor=white)
![Wayland](https://img.shields.io/badge/Display-Wayland-purple)
![NVIDIA Proprietary](https://img.shields.io/badge/NVIDIA-.run%20driver-76B900?logo=nvidia\&logoColor=white)
![Systemd](https://img.shields.io/badge/Init-systemd-000000?logo=systemd\&logoColor=white)
![License](https://img.shields.io/badge/license-See%20LICENSE-blue)

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

---

## 🩺 Troubleshooting

### O serviço não executou no boot

Verifique o status:

```bash
systemctl status nvidia-rebuild.service
journalctl -u nvidia-rebuild.service -b
```

### O log mostra erro de compilação DKMS

Confirme que os headers estão instalados:

```bash
pacman -Qs linux-lts-headers
```

### O `.run` não foi encontrado

Edite o caminho dentro de:

```
/usr/local/bin/nvidia-rebuild.sh
```

E confirme que o arquivo existe e é executável.

### Wayland não sobe após atualização

Confira o log gerado:

```bash
cat /var/log/nvidia-rebuild.log
```

Quase sempre o problema é caminho incorreto do `.run` ou headers ausentes.

---

## 🎥 Demonstração do boot automático

Você pode gravar um GIF do processo para mostrar o serviço rodando antes do gráfico.

Sugestão usando tty e `asciinema`:

```bash
asciinema rec boot.cast
```

Depois converta para GIF e adicione aqui:

```markdown
![boot-demo](docs/boot-demo.gif)
```

Isso ajuda muito quem visita o repositório a entender o funcionamento visualmente.
