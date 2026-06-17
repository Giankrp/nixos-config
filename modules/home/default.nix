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
  xdg.configFile."ags/app.js".text = ''
    import { App, Astal, Gtk } from "astal/gtk3";
    import { Variable, bind, execAsync } from "astal";

    const time = Variable("").poll(1000, ["date", "+%a %b %d, %H:%M"]);
    const volumeRaw = Variable("").poll(1000, ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]);
    const batteryRaw = Variable("").poll(5000, ["sh", "-c", "echo \"$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 0) $(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo Unknown)\""]);
    const wifiRaw = Variable("").poll(5000, ["sh", "-c", "nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2 || true"]);
    const cpuRaw = Variable("").poll(2000, ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print 100 - $1}'"]);
    const ramRaw = Variable("").poll(2000, ["sh", "-c", "free -m | awk '/Mem:/ {printf \"%d\", $3/$2*100}'"]);
    const niriStateRaw = Variable('{"workspaces":[],"windows":[]}').poll(500, ["sh", "-c", "echo \"{ \\\"workspaces\\\": $(niri msg -j workspaces 2>/dev/null || echo '[]'), \\\"windows\\\": $(niri msg -j windows 2>/dev/null || echo '[]') }\""]);

    const getAppIcon = (appId) => {
        if (!appId) return "󰖲";
        const id = appId.toLowerCase();
        if (id.includes("firefox")) return "󰈹";
        if (id.includes("chrome") || id.includes("chromium")) return "󰊯";
        if (id.includes("kitty") || id.includes("alacritty") || id.includes("terminal") || id.includes("wezterm")) return "";
        if (id.includes("code") || id.includes("visual-studio")) return "󰨞";
        if (id.includes("nvim") || id.includes("neovim")) return "";
        if (id.includes("discord") || id.includes("vesktop")) return "󰙯";
        if (id.includes("spotify")) return "󰓇";
        if (id.includes("steam")) return "󰓓";
        if (id.includes("nautilus") || id.includes("thunar") || id.includes("dolphin") || id.includes("yazi")) return "󰉋";
        if (id.includes("slack")) return "󰒱";
        if (id.includes("telegram")) return "󰔗";
        if (id.includes("thunderbird")) return "󰻧";
        return "󰖲";
    };

    function Workspaces() {
        return (
            <box className="workspaces">
                {bind(niriStateRaw).as(raw => {
                    try {
                        const state = JSON.parse(raw);
                        const workspaces = state.workspaces || [];
                        const windows = state.windows || [];
                        
                        if (!Array.isArray(workspaces) || workspaces.length === 0) {
                            return [<label label="•" />];
                        }
                        
                        workspaces.sort((a, b) => a.idx - b.idx);
                        
                        return workspaces.map(ws => {
                            const wsWindows = windows.filter(w => w.workspace_id === ws.id);
                            
                            let className = "workspace-pill";
                            if (ws.is_focused) className += " focused";
                            else if (wsWindows.length > 0) className += " active";
                            else className += " empty";
                            
                            const icons = wsWindows.map(w => getAppIcon(w.app_id));
                            const uniqueIcons = [...new Set(icons)];
                            
                            return (
                                <button
                                    className={className}
                                    onClicked={() => {
                                        execAsync(`niri msg action focus-workspace ` + ws.idx);
                                    }}
                                >
                                    <box className="workspace-content">
                                        <label className="workspace-index" label={ws.idx.toString()} />
                                        {uniqueIcons.length > 0 && (
                                            <box className="workspace-icons">
                                                {uniqueIcons.map(icon => (
                                                    <label className="workspace-icon" label={` ` + icon} />
                                                ))}
                                            </box>
                                        )}
                                    </box>
                                </button>
                            );
                        });
                    } catch (e) {
                        return [<label label="•" />];
                    }
                })}
            </box>
        );
    }

    function Bar(monitor = 0) {
        return (
            <window
                className="bar-window"
                monitor={monitor}
                exclusivity={Astal.Exclusivity.EXCLUSIVE}
                anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT}
            >
                <centerbox
                    className="bar-container"
                    startWidget={
                        <box className="left-modules">
                            <box className="module logo-module">
                                <label className="logo" label="❄️ NixOS" />
                            </box>
                            <Workspaces />
                        </box>
                    }
                    centerWidget={
                        <box className="center-modules">
                            <box className="module clock-module">
                                <label className="clock" label={bind(time)} />
                            </box>
                        </box>
                    }
                    endWidget={
                        <box className="right-modules">
                            <box className="module cpu-ram-module">
                                <label className="cpu" label={bind(cpuRaw).as(c => `󰍛 ` + c.trim() + `%`)} />
                                <label className="ram" label={bind(ramRaw).as(r => ` 󰘚 ` + r.trim() + `%`)} />
                            </box>
                            <box className="module wifi-module">
                                <label className="wifi" label={bind(wifiRaw).as(w => {
                                    const ssid = w.trim();
                                    return ssid ? `󰤨 ` + ssid : "󰤮 Disconnected";
                                })} />
                            </box>
                            <box className="module volume-module">
                                <label className="volume" label={bind(volumeRaw).as(v => {
                                    if (!v) return "󰕾 --%";
                                    if (v.includes("[MUTED]")) return "󰝟 Muted";
                                    const num = parseFloat(v.replace("Volume: ", "").trim());
                                    const pct = Math.round(num * 100);
                                    let icon = "󰕾";
                                    if (pct === 0) icon = "󰝟";
                                    else if (pct < 30) icon = "󰕿";
                                    else if (pct < 70) icon = "󰖀";
                                    return icon + ` ` + pct + `%`;
                                })} />
                            </box>
                            <box className="module battery-module">
                                <label className="battery" label={bind(batteryRaw).as(b => {
                                    if (!b) return "󰂎 --%";
                                    const parts = b.split(" ");
                                    const cap = parseInt(parts[0]);
                                    const status = parts[1] ? parts[1].trim() : "";
                                    let icon = "󰁹";
                                    if (status === "Charging") {
                                        icon = "󰂄";
                                    } else {
                                        if (cap < 10) icon = "󰁺";
                                        else if (cap < 20) icon = "󰁻";
                                        else if (cap < 30) icon = "󰁼";
                                        else if (cap < 40) icon = "󰁽";
                                        else if (cap < 50) icon = "󰁾";
                                        else if (cap < 60) icon = "󰁿";
                                        else if (cap < 70) icon = "󰂀";
                                        else if (cap < 80) icon = "󰂁";
                                        else if (cap < 90) icon = "󰂂";
                                    }
                                    return icon + ` ` + cap + `%`;
                                })} />
                            </box>
                        </box>
                    }
                />
            </window>
        );
    }

    App.start({
        css: "/home/gian/.config/ags/style.css",
        main: () => {
            App.add_window(Bar(0));
        }
    });
  '';

  xdg.configFile."ags/style.css".text = ''
    * {
        font-family: "CaskaydiaCove Nerd Font", sans-serif;
        font-size: 13px;
    }

    window {
        background-color: transparent;
        background: none;
    }

    .bar-container {
        background-color: rgba(30, 30, 46, 0.85);
        border: 1px solid #313244;
        border-radius: 12px;
        margin: 8px 12px 0 12px;
        padding: 4px 8px;
        color: #cdd6f4;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
    }

    .module {
        background-color: #181825;
        border: 1px solid #313244;
        border-radius: 8px;
        padding: 4px 12px;
        margin: 2px 4px;
        color: #cdd6f4;
    }

    .logo-module {
        background-color: rgba(137, 180, 250, 0.15);
        border-color: #89b4fa;
        color: #89b4fa;
        font-weight: bold;
    }

    .logo {
        font-weight: bold;
        color: #89b4fa;
    }

    .workspaces {
        margin-left: 4px;
    }

    button.workspace-pill {
        background-color: rgba(24, 24, 37, 0.4);
        border: 1px solid #313244;
        border-radius: 8px;
        padding: 4px 10px;
        margin: 2px 4px;
        color: #7f849c;
        transition: all 0.2s ease;
    }

    button.workspace-pill:hover {
        background-color: rgba(49, 50, 68, 0.6);
        color: #cdd6f4;
        border-color: #cba6f7;
    }

    button.workspace-pill.active {
        color: #b4befe;
        border-color: #45475a;
    }

    button.workspace-pill.focused {
        background-color: #cba6f7;
        color: #11111b;
        border-color: #cba6f7;
        font-weight: bold;
    }

    button.workspace-pill.focused label {
        color: #11111b;
    }

    .workspace-index {
        font-weight: bold;
    }

    .workspace-icons {
        margin-left: 4px;
    }

    .workspace-icon {
        font-size: 14px;
    }

    .clock-module {
        background-color: rgba(245, 194, 231, 0.15);
        border-color: #f5c2e7;
        color: #f5c2e7;
        font-weight: bold;
    }

    .clock {
        font-weight: bold;
        color: #f5c2e7;
    }

    .cpu-ram-module {
        color: #f9e2af;
    }

    .cpu {
        color: #f9e2af;
        margin-right: 8px;
    }

    .ram {
        color: #f38ba8;
    }

    .wifi-module {
        color: #89dceb;
    }

    .volume-module {
        color: #a6e3a1;
    }

    .battery-module {
        color: #fab387;
    }
  '';
}
