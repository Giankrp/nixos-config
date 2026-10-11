{ config, pkgs, inputs, ... }:

{
  # Global Catppuccin theme configuration
  catppuccin.enable = true;
  catppuccin.flavor = "mocha";
  catppuccin.autoEnable = true;
  catppuccin.zed.enable = false;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "gian";
  home.homeDirectory = "/home/gian";

  # Match the release version of your system
  home.stateVersion = "26.05";

  # User packages
  home.packages = with pkgs; [
    satty
    mpvpaper
    (ags.override {
      extraPackages = [
        astal.apps
      ];
    })

    # Go development tools (LSPs, linters, formatters)
    gopls
    golangci-lint
    gofumpt
    air
    sqlc

    # Web development tools (LSPs, Linters, Formatters)
    vtsls
    vue-language-server
    tailwindcss-language-server
    angular-language-server
    prettier
    oxlint
    oxfmt
    eslint

    # Nix development tools
    nil
    nixd
    nixfmt-rfc-style
    nix-tree

    # Terminal UI and general CLI development tools
    lazydocker
    lazysql
    jq
    yq-go
    shellcheck
    shfmt
    just

    # Desktop and Multimedia applications
    vesktop
    mpv
    celluloid
    imv
    obsidian
    pavucontrol

    # Zen Browser wrapped with ffmpeg and pipewire for MSE / H.264 video decoding (Twitch, Twitter, etc.)
    (symlinkJoin {
      name = "zen-browser";
      paths = [ inputs.zen-browser.packages.${pkgs.system}.default ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram "$out/bin/zen" \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ ffmpeg pipewire ]}"
      '';
    })
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
      zj = "zellij";
    };

    initContent = ''
      fastfetch
    '';
  };

  # Starship prompt configuration managed by Home Manager
  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./starship.toml);
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    shortcut = "space"; # prefix C-Space

    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.catppuccin
    ];

    extraConfig = builtins.readFile ./tmux.conf;
  };

  # Zellij configuration
  programs.zellij = {
    enable = true;
    extraConfig = builtins.readFile ./zellij/config.kdl;
  };

  # Fastfetch configuration and ASCII logo
  xdg.configFile."fastfetch/logo.txt".source = ./fastfetch/logo.txt;

  xdg.configFile."fastfetch/config.jsonc".source = ./fastfetch/config.jsonc;

  # OpenCode configuration
  xdg.configFile."opencode/opencode.jsonc".source = ./. + "/Gian agent.json";
  xdg.configFile."opencode/AGENTS.md".source = ./AGENTS.md;

  # Direnv configuration for automatic environment loading (flakewise)
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Git configuration managed by Home Manager
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Giankrp";
        email = "gianruiz2003@gmail.com";
      };
      safe = {
        directory = "/etc/nixos";
      };
    };
  };

  # Lazygit configuration managed by Home Manager
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        showIcons = true;
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

  # Mako notification daemon configuration
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      font = "CaskaydiaCove NF SemiBold 11";
      border-size = 2;
      border-radius = 12;
      padding = "12,16";
      margin = "12";
    };
  };

  # Link Niri configuration file
  xdg.configFile."niri/config.kdl".source = ./niri.kdl;

  # AGS (Aylur's GTK Shell) configuration files
  xdg.configFile."ags/app.js".source = ./ags/app.js;
  xdg.configFile."ags/style.css".source = ./ags/style.css;
  xdg.configFile."ags/wallpaper.jpg".source = ./ags/wallpaper.jpg;

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in {
      enable = true;
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";

      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
        shuffle
      ];
    };

  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor-fhs;

    extensions = [
      "nix"
      "catppuccin"
      "golang"
      "vue"
      "html"
      "tailwind"
      "crystal"
      "java"
      "angular"
    ];

    userSettings = builtins.fromJSON (builtins.readFile ./zed/settings.json);
    userKeymaps = builtins.fromJSON (builtins.readFile ./zed/keymap.json);
  };
}
