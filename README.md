# NixOS Config - Multi-Host Niri & AGS Style

Este repositorio contiene la configuración declarativa, reproducible y multi-host de NixOS utilizando **Nix Flakes**, **Home Manager**, el compositor Wayland **Niri** y **AGS** (Aylur's GTK Shell) para la barra de estado.

---

## 📁 Estructura del Proyecto

*   `flake.nix`: Definición de entradas, salidas y hosts del sistema (`desktop` y `laptop`).
*   `hosts/`: Configuraciones a nivel de sistema.
    *   `configuration.nix`: Configuración común del sistema compartida por todas las máquinas (usuarios, Docker, Zsh, audio, etc.).
    *   `desktop/`: Configuración específica para el PC de escritorio.
        *   `default.nix`: Definición del hostname (`desktop`) e importación de la configuración común.
        *   `hardware-configuration.nix`: Hardware específico del PC de escritorio.
    *   `laptop/`: Configuración específica para el portátil.
        *   `default.nix`: Definición del hostname (`laptop`) e importación de la configuración común.
        *   `hardware-configuration.nix`: Hardware específico del portátil.
*   `modules/home/`: Entorno de usuario administrado por Home Manager (compartido por todas las máquinas).
    *   `default.nix`: Activación y configuración de programas (Git, Lazygit, Kitty, Direnv, Mako, Zed con LSPs).
    *   `niri.kdl`: Configuración del compositor de mosaico dinámico Niri.
    *   `tmux.conf`: Configuración del multiplexor de terminal Tmux (Catppuccin Mocha).
    *   `ags/`: Barra de estado modular en Javascript (AGS) con widgets.
    *   `fastfetch/`: Logotipo ASCII y telemetría Fastfetch.

---

## 🚀 Instalación y Despliegue

Sigue estos pasos para instalar y desplegar esta configuración en un nuevo equipo:

### 1. Clonar el repositorio
Clona esta configuración directamente en el directorio estándar `/etc/nixos/`:
```bash
sudo rm -rf /etc/nixos
sudo git clone https://github.com/Giankrp/nixos-config.git /etc/nixos
```

### 2. Generar y sobreescribir la configuración de hardware
Genera una nueva configuración de hardware específica para la máquina de destino (esto detectará tus discos, particiones y drivers de CPU/GPU):

*   **Si estás instalando en el Portátil:**
    ```bash
    sudo nixos-generate-config --show-hardware-config > /etc/nixos/hosts/laptop/hardware-configuration.nix
    ```
*   **Si estás instalando en el PC de Escritorio:**
    ```bash
    sudo nixos-generate-config --show-hardware-config > /etc/nixos/hosts/desktop/hardware-configuration.nix
    ```

### 3. Registrar los cambios en Git
> [!IMPORTANT]
> Nix Flakes ignora cualquier archivo que no esté rastreado por Git. Añade la nueva configuración de hardware al repositorio antes de compilar:

*   **Para el Portátil:**
    ```bash
    sudo git -C /etc/nixos add -f hosts/laptop/hardware-configuration.nix
    ```
*   **Para el PC de Escritorio:**
    ```bash
    sudo git -C /etc/nixos add -f hosts/desktop/hardware-configuration.nix
    ```
*Si omites este paso, la compilación fallará alegando que no se encuentra el archivo de configuración de hardware.*

### 4. Compilar y aplicar la configuración
Usa el flag `--flake` apuntando a tu máquina correspondiente:

*   **Para el Portátil:**
    ```bash
    sudo nixos-rebuild switch --flake /etc/nixos#laptop
    ```
*   **Para el PC de Escritorio:**
    ```bash
    sudo nixos-rebuild switch --flake /etc/nixos#desktop
    ```

---

## 💻 Gestión de Múltiples Máquinas

El repositorio está estructurado para que compartas el 100% de tus programas y personalización de usuario (`modules/home/default.nix`) y configuraciones globales del sistema (`hosts/configuration.nix`), manteniendo separados de forma limpia los hostname y hardware de cada equipo.

### ¿Cómo añadir un tercer equipo?
Si deseas añadir otra máquina (por ejemplo, `servidor`):
1.  Crea una nueva carpeta `hosts/servidor/` con un archivo `default.nix` que apunte a su respectivo `hardware-configuration.nix` y defina su hostname.
2.  Declara el nuevo host en la sección `outputs.nixosConfigurations` de tu `flake.nix`.
3.  Compila con:
    ```bash
    sudo nixos-rebuild switch --flake /etc/nixos#servidor
    ```

---

## 🛠️ Mantenimiento y Modificaciones

Cada vez que realices cambios en los archivos de configuración, debes seguir estos pasos para aplicarlos:

1.  Asegúrate de registrar cualquier cambio en Git (Nix Flakes lo requiere):
    ```bash
    sudo git -C /etc/nixos add -A
    ```
2.  Reconstruye tu sistema NixOS según la máquina en la que te encuentres:
    *   **En el Portátil:**
        ```bash
        sudo nixos-rebuild switch --flake /etc/nixos#laptop
        ```
    *   **En el PC de Escritorio:**
        ```bash
        sudo nixos-rebuild switch --flake /etc/nixos#desktop
        ```
3.  Reinicia el servicio de AGS para ver los cambios aplicados en la barra de estado:
    ```bash
    pkill -9 -f ags; pkill -9 -f gjs; ags run &
    ```
