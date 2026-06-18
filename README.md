# NixOS Config - Niri & AGS Style

Este repositorio contiene la configuración declarativa y reproducible de NixOS utilizando **Nix Flakes**, **Home Manager**, el compositor Wayland **Niri** y **AGS** (Aylur's GTK Shell) para la barra de estado.

---

## 📁 Estructura del Proyecto

*   `flake.nix`: Definición de entradas, salidas y dependencias (Nixpkgs Unstable, Catppuccin, Spicetify, Zen Browser).
*   `hosts/nixos/`: Configuraciones del sistema base para el host actual.
    *   `default.nix`: Configuración general del sistema (usuarios, grupos, servicios de audio, Docker, etc.).
    *   `hardware-configuration.nix`: Especificación del hardware (discos, CPU, GPU, controladores de arranque).
*   `modules/home/`: Configuración del entorno de usuario administrada por Home Manager.
    *   `default.nix`: Activación de programas principales (Git, Lazygit, Kitty, Direnv, Mako, Zed).
    *   `niri.kdl`: Configuración del compositor de mosaico dinámico Niri.
    *   `tmux.conf`: Configuración del multiplexor de terminal Tmux (Catppuccin Mocha).
    *   `ags/`: Barra de estado modular en Javascript (AGS) con widgets.
    *   `fastfetch/`: Logotipo ASCII y configuración modular de telemetría Fastfetch.

---

## 🚀 Instalación en un nuevo equipo

Para clonar y desplegar esta configuración en una nueva máquina, sigue estos pasos:

### 1. Clonar el repositorio
Clona esta configuración directamente en el directorio estándar `/etc/nixos/`:
```bash
sudo rm -rf /etc/nixos
sudo git clone https://github.com/Giankrp/nixos-config.git /etc/nixos
```

### 2. Generar y sobreescribir la configuración de hardware
Dado que el hardware de cada equipo es diferente (discos, drivers de CPU/GPU, etc.), debes generar una nueva configuración de hardware específica para la máquina de destino:
```bash
sudo nixos-generate-config --show-hardware-config > /etc/nixos/hosts/nixos/hardware-configuration.nix
```

### 3. Registrar el nuevo archivo en Git
> [!IMPORTANT]
> Nix Flakes ignora cualquier archivo que no esté rastreado por Git. Añade la nueva configuración de hardware al repositorio antes de compilar:
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

## 💻 Gestión de Múltiples Máquinas (Multi-Host)

Si deseas tener dos o más máquinas (por ejemplo, tu PC de Escritorio y tu Portátil) compartiendo el mismo repositorio sin que sus archivos de hardware entren en conflicto, sigue esta estructura recomendada:

### 1. Estructura de carpetas por hostname
Renombra la carpeta `hosts/nixos` según el hostname de cada máquina:
```
hosts/
├── pc-escritorio/
│   ├── default.nix
│   └── hardware-configuration.nix
└── portatil/
    ├── default.nix
    └── hardware-configuration.nix
```

### 2. Actualizar `flake.nix`
Declara ambos hosts en la sección `outputs` de tu `flake.nix`:
```nix
outputs = { self, nixpkgs, home-manager, ... }@inputs: {
  nixosConfigurations = {
    # Configuración de tu PC de Escritorio
    pc-escritorio = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/pc-escritorio/default.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.users.gian = import ./modules/home/default.nix;
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };

    # Configuración de tu Portátil
    portatil = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/portatil/default.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.users.gian = import ./modules/home/default.nix;
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };
  };
};
```
*De este modo, ambas máquinas cargarán su hardware respectivo, pero compartirán el mismo módulo común de usuario (`modules/home/default.nix`).*

### 3. Reconstruir según la máquina activa
* En tu PC de escritorio ejecuta:
  ```bash
  sudo nixos-rebuild switch --flake /etc/nixos#pc-escritorio
  ```
* En tu portátil ejecuta:
  ```bash
  sudo nixos-rebuild switch --flake /etc/nixos#portatil
  ```

---

## 🛠️ Mantenimiento y Modificaciones

Cada vez que realices cambios en los archivos de configuración, debes seguir estos pasos para aplicarlos:

1.  Asegúrate de registrar cualquier cambio nuevo en Git (Nix Flakes lo requiere):
    ```bash
    sudo git -C /etc/nixos add -A
    ```
2.  Reconstruye tu sistema NixOS:
    ```bash
    sudo nixos-rebuild switch --flake /etc/nixos#nixos
    ```
3.  Reinicia el servicio de AGS para ver los cambios aplicados en la barra de estado:
    ```bash
    pkill -9 -f ags; pkill -9 -f gjs; ags run &
    ```
