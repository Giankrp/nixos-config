{ config, pkgs, ... }:

{
  # Global Catppuccin theme configuration
  catppuccin.enable = true;
  catppuccin.flavor = "mocha";
  catppuccin.autoEnable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "gian";
  home.homeDirectory = "/home/gian";

  # Match the release version of your system
  home.stateVersion = "26.05";

  # User packages
  home.packages = with pkgs; [
    satty
    ags
  ];

  # Add directories to PATH
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.local/share/pnpm/bin"
  ];

  # Define environment variables
  home.sessionVariables = {
    PNPM_HOME = "$HOME/.local/share/pnpm/bin";
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Zsh configuration managed by Home Manager
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    shellAliases = {
      v = "nvim";
      gs = "git status";
      ls = "lsd";
    };

    initContent = ''
      eval "$(starship init zsh)"
      fastfetch
    '';
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    shortcut = "space"; # prefix C-Space

    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.catppuccin
    ];

    extraConfig = ''
      # Shell configuration
      set -g default-shell "/run/current-system/sw/bin/zsh"

      # Mappings
      bind -n M-H previous-window
      bind -n M-L next-window 

      # Open in current directory
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # Catppuccin theme customization
      set -g @catppuccin_flavor 'mocha'

      # Status bar configuration
      set -g @catppuccin_window_left_separator ""
      set -g @catppuccin_window_right_separator " "
      set -g @catppuccin_window_middle_separator " █"
      set -g @catppuccin_window_number_position "right"

      set -g @catppuccin_window_default_fill "number"
      set -g @catppuccin_window_default_text "#W"

      set -g @catppuccin_window_current_fill "number"
      set -g @catppuccin_window_current_text "#W"

      set -g @catppuccin_status_modules_right "directory git session"
      set -g @catppuccin_status_left_separator  " "
      set -g @catppuccin_status_right_separator ""
      set -g @catppuccin_status_right_separator_inverse "no"
      set -g @catppuccin_status_fill "icon"
      set -g @catppuccin_status_connect_separator "no"

      set -g @catppuccin_directory_text "#{pane_current_path}"
    '';
  };

  # Fastfetch configuration and ASCII logo
  xdg.configFile."fastfetch/logo.txt".text = ''




  ⠄⠄⠄⢰⣧⣼⣯⠄⣸⣠⣶⣶⣦⣾⠄⠄⠄⠄⡀⠄⢀⣿⣿⠄⠄⠄⢸⡇⠄⠄
  ⠄⠄⠄⣾⣿⠿⠿⠶⠿⢿⣿⣿⣿⣿⣦⣤⣄⢀⡅⢠⣾⣛⡉⠄⠄⠄⠸⢀⣿⠄
  ⠄⠄⢀⡋⣡⣴⣶⣶⡀⠄⠄⠙⢿⣿⣿⣿⣿⣿⣴⣿⣿⣿⢃⣤⣄⣀⣥⣿⣿⠄
  ⠄⠄⢸⣇⠻⣿⣿⣿⣧⣀⢀⣠⡌⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠿⣿⣿⣿⠄
  ⠄⢀⢸⣿⣷⣤⣤⣤⣬⣙⣛⢿⣿⣿⣿⣿⣿⣿⡿⣿⣿⡍⠄⠄⢀⣤⣄⠉⠋⣰
  ⠄⣼⣖⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⢇⣿⣿⡷⠶⠶⢿⣿⣿⠇⢀⣤
  ⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣽⣿⣿⣿⡇⣿⣿⣿⣿⣿⣿⣷⣶⣥⣴⣿⡗
  ⢀⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠄
  ⢸⣿⣦⣌⣛⣻⣿⣿⣧⠙⠛⠛⡭⠅⠒⠦⠭⣭⡻⣿⣿⣿⣿⣿⣿⣿⣿⡿⠃⠄
  ⠘⣿⣿⣿⣿⣿⣿⣿⣿⡆⠄⠄⠄⠄⠄⠄⠄⠄⠹⠈⢋⣽⣿⣿⣿⣿⣵⣾⠃⠄
  ⠄⠘⣿⣿⣿⣿⣿⣿⣿⣿⠄⣴⣿⣶⣄⠄⣴⣶⠄⢀⣾⣿⣿⣿⣿⣿⣿⠃⠄⠄
  ⠄⠄⠈⠻⣿⣿⣿⣿⣿⣿⡄⢻⣿⣿⣿⠄⣿⣿⡀⣾⣿⣿⣿⣿⣛⠛⠁⠄⠄⠄
  ⠄⠄⠄⠄⠈⠛⢿⣿⣿⣿⠁⠞⢿⣿⣿⡄⢿⣿⡇⣸⣿⣿⠿⠛⠁⠄⠄⠄⠄⠄
  ⠄⠄⠄⠄⠄⠄⠄⠉⠻⣿⣿⣾⣦⡙⠻⣷⣾⣿⠃⠿⠋⠁⠄⠄⠄⠄⠄⢀⣠⣴
  ⣿⣿⣿⣶⣶⣮⣥⣒⠲⢮⣝⡿⣿⣿⡆⣿⡿⠃⠄⠄⠄⠄⠄⠄⠄⣠⣴⣿⣿⣿
  '';

  xdg.configFile."fastfetch/config.jsonc".text = ''
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "source": "~/.config/fastfetch/logo.txt",
        "type": "auto"
    },
    "modules": [
        "break",
        {
            "type": "custom",
            "format": "\u001b[90m┌──────────────────────Hardware──────────────────────┐"
        },
        {
            "type": "host",
            "key": " PC",
            "keyColor": "green"
        },
        {
            "type": "cpu",
            "key": "│ ├",
            "showPeCoreCount": true,
            "keyColor": "green"
        },
        {
            "type": "gpu",
            "key": "│ ├",
            "keyColor": "green"
        },
        {
            "type": "memory",
            "key": "│ ├",
            "keyColor": "green"
        },
        {
            "type": "disk",
            "key": "└ └",
            "keyColor": "green"
        },
        {
            "type": "custom",
            "format": "\u001b[90m└────────────────────────────────────────────────────┘"
        },
        "break",
        {
            "type": "custom",
            "format": "\u001b[90m┌──────────────────────Software──────────────────────┐"
        },
        {
            "type": "os",
            "key": " OS",
            "keyColor": "yellow"
        },
        {
            "type": "kernel",
            "key": "│ ├",
            "keyColor": "yellow"
        },
        {
            "type": "packages",
            "key": "│ ├",
            "keyColor": "yellow"
        },
        {
            "type": "shell",
            "key": "└ └",
            "keyColor": "yellow"
        },
        "break",
        {
            "type": "de",
            "key": " DE",
            "keyColor": "blue"
        },
        {
            "type": "lm",
            "key": "│ ├",
            "keyColor": "blue"
        },
        {
            "type": "wm",
            "key": "│ ├",
            "keyColor": "blue"
        },
        {
            "type": "wmtheme",
            "key": "│ ├",
            "keyColor": "blue"
        },
        {
            "type": "gpu",
            "key": "└ └",
            "format": "{3}",
            "keyColor": "blue"
        },
        {
            "type": "custom",
            "format": "\u001b[90m└────────────────────────────────────────────────────┘"
        },
        "break",
        {
            "type": "custom",
            "format": "\u001b[90m┌────────────────────Uptime / Age────────────────────┐"
        },
        {
            "type": "command",
            "key": "  OS Age ",
            "keyColor": "magenta",
            "text": "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days"
        },
        {
            "type": "uptime",
            "key": "  Uptime ",
            "keyColor": "magenta"
        },
        {
            "type": "custom",
            "format": "\u001b[90m└────────────────────────────────────────────────────┘"
        },
        "break"
    ]
}
  '';

  # Git configuration managed by Home Manager
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Giankrp";
        email = "gianruzi2003@gmail.com";
      };
      safe = {
        directory = "/etc/nixos";
      };
    };
  };

  # Kitty configuration managed by Home Manager
  programs.kitty = {
    enable = true;
    font = {
      name = "CaskaydiaCove NF SemiBold";
      size = 13;
    };
    settings = {
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      hide_window_decorations = "yes";
      shell = "zsh";
    };
  };

  # Link Niri configuration file
  xdg.configFile."niri/config.kdl".source = ./niri.kdl;

  # AGS (Aylur's GTK Shell) configuration files
  xdg.configFile."ags/config.js".text = ''
    import App from 'resource:///com/github/aylur/ags/app.js';
    import Widget from 'resource:///com/github/aylur/ags/widget.js';
    import Audio from 'resource:///com/github/aylur/ags/service/audio.js';
    import Battery from 'resource:///com/github/aylur/ags/service/battery.js';

    // Clock Widget
    const Clock = () => Widget.Label({
        className: 'clock',
        setup: self => self.poll(1000, self => {
            const date = new Date();
            self.label = date.toLocaleDateString('es-ES', {
                weekday: 'short',
                month: 'short',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
            });
        }),
    });

    // Battery Widget
    const BatteryLabel = () => Widget.Box({
        className: 'battery',
        visible: Battery.bind('available'),
        children: [
            Widget.Icon({
                icon: Battery.bind('icon_name'),
            }),
            Widget.Label({
                label: Battery.bind('percent').as(p => ` ''${p}%`),
            }),
        ],
    });

    // Volume Widget
    const Volume = () => Widget.Box({
        className: 'volume',
        children: [
            Widget.Icon({
                icon: Audio.speaker.bind('volume').as(v => {
                    if (v === 0) return 'audio-volume-muted-symbolic';
                    if (v < 0.33) return 'audio-volume-low-symbolic';
                    if (v < 0.66) return 'audio-volume-medium-symbolic';
                    return 'audio-volume-high-symbolic';
                }),
            }),
            Widget.Label({
                label: Audio.speaker.bind('volume').as(v => ` ''${Math.round(v * 100)}%`),
            }),
        ],
    });

    const Left = () => Widget.Box({
        spacing: 8,
        children: [
            Widget.Label({
                className: 'logo',
                label: '❄️ NixOS',
            }),
        ],
    });

    const Center = () => Widget.Box({
        spacing: 8,
        children: [
            Clock(),
        ],
    });

    const Right = () => Widget.Box({
        hpack: 'end',
        spacing: 12,
        children: [
            Volume(),
            BatteryLabel(),
        ],
    });

    const Bar = (monitor = 0) => Widget.Window({
        name: `bar-''${monitor}`,
        className: 'bar',
        monitor,
        anchor: ['top', 'left', 'right'],
        exclusivity: 'exclusive',
        child: Widget.CenterBox({
            startWidget: Left(),
            centerWidget: Center(),
            endWidget: Right(),
        }),
    });

    App.config({
        style: App.configDir + '/style.css',
        windows: [
            Bar(0),
        ],
    });
  '';

  xdg.configFile."ags/style.css".text = ''
    * {
        font-family: "CaskaydiaCove Nerd Font", sans-serif;
        font-size: 13px;
    }

    window.bar {
        background-color: #1e1e2e;
        border-bottom: 2px solid #cba6f7;
        color: #cdd6f4;
    }

    .logo {
        color: #89b4fa;
        font-weight: bold;
        margin-left: 15px;
        padding: 6px 0;
    }

    .clock {
        color: #f5c2e7;
        font-weight: bold;
        padding: 6px 0;
    }

    .volume {
        color: #a6e3a1;
        margin-right: 15px;
        padding: 6px 0;
    }

    .battery {
        color: #f9e2af;
        margin-right: 15px;
        padding: 6px 0;
    }
  '';
}
