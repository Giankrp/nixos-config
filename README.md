# NixOS Config - Niri & AGS Style

Este repositorio contiene la configuración declarativa y reproducible de NixOS utilizando **Nix Flakes**, **Home Manager**, el compositor Wayland **Niri** y **AGS** (Aylur's GTK Shell) para la barra de estado.

## 📁 Estructura del Proyecto

*   `flake.nix`: Definición de entradas, salidas y dependencias del sistema.
*   `hosts/nixos/`: Configuraciones específicas a nivel de sistema.
    *   `default.nix`: Configuración general del sistema (usuarios, servicios, redes, etc.).
    *   `hardware-configuration.nix`: Configuración de hardware específica del dispositivo actual.
*   `modules/home/`: Configuración a nivel de usuario (Home Manager).
    *   `default.nix`: Inicialización y mapeo de configuraciones (Zsh, Tmux, Kitty, AGS).
    *   `niri.kdl`: Configuración del compositor de ventanas Niri.
    *   `ags/`: Configuración modular de la barra de estado.
        *   `app.js`: Lógica y estructura de los widgets de AGS en Javascript.
        *   `style.css`: Estilos de los widgets en CSS de GTK3 (Catppuccin Mocha).

---

## 🚀 Instalación en un nuevo equipo

Para clonar y desplegar esta configuración en una nueva máquina, sigue estos pasos:

### 1. Clonar el repositorio
Clona esta configuración directamente en el directorio estándar `/etc/nixos/`:
```bash
sudo rm -rf /etc/nixos
sudo git clone <URL_DE_TU_REPO> /etc/nixos
```

### 2. Generar y sobreescribir la configuración de hardware
Dado que el hardware de cada equipo es diferente (discos, drivers de CPU/GPU, etc.), debes generar una nueva configuración de hardware específica para la máquina de destino:
```bash
sudo nixos-generate-config --show-hardware-config > /etc/nixos/hosts/nixos/hardware-configuration.nix
```

### 3. Registrar el nuevo archivo en Git
**¡Crucial!** Nix Flakes ignora cualquier archivo que no esté rastreado por Git. Añade la nueva configuración de hardware al repositorio:
```bash
sudo git -C /etc/nixos add -f hosts/nixos/hardware-configuration.nix
```
*Si omites este paso, la compilación fallará alegando que no se encuentra `./hardware-configuration.nix`.*

### 4. Compilar y aplicar la configuración
Usa el flag `--flake` apuntando a la configuración del host `nixos`:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

---

## 🛠️ Mantenimiento y Modificaciones

Cada vez que realices cambios en los archivos de configuración (por ejemplo, en `app.js` o `style.css`), debes seguir estos pasos para aplicarlos:

1.  Asegúrate de registrar cualquier cambio en Git (Nix Flakes lo requiere):
    ```bash
    sudo git -C /etc/nixos add -u
    ```
2.  Reconstruye tu sistema NixOS:
    ```bash
    sudo nixos-rebuild switch --flake /etc/nixos
    ```
3.  Reinicia el servicio de AGS para ver los cambios aplicados en la barra de estado:
    ```bash
    pkill -9 -f ags; pkill -9 -f gjs; ags run &
    ```
