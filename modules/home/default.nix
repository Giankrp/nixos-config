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

    # Desktop and Multimedia applications
    discord
    mpv
    imv

    # Zen Browser (installed from community flake input)
    inputs.zen-browser.packages.${pkgs.system}.default
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

    extraConfig = builtins.readFile ./tmux.conf;
  };

  # Fastfetch configuration and ASCII logo
  xdg.configFile."fastfetch/logo.txt".source = ./fastfetch/logo.txt;

  xdg.configFile."fastfetch/config.jsonc".source = ./fastfetch/config.jsonc;

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
        email = "gianruzi2003@gmail.com";
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
    ];

    userSettings = {
      semantic_tokens = "combined";
      code_lens = "on";
      jsx_tag_auto_close = {
        enabled = true;
      };
      cli_default_open_behavior = "existing_window";
      outline_panel = {
        dock = "right";
      };
      collaboration_panel = {
        dock = "right";
      };
      agent = {
        sidebar_side = "left";
        favorite_models = [ ];
        model_parameters = [ ];
        dock = "right";
      };
      colorize_brackets = true;
      inlay_hints = {
        enabled = false;
        show_background = false;
      };
      toolbar = {
        code_actions = false;
        breadcrumbs = true;
        selections_menu = false;
      };
      git_panel = {
        dock = "right";
        tree_view = true;
      };
      disable_ai = false;
      project_panel = {
        drag_and_drop = true;
        sticky_scroll = true;
        starts_open = true;
        git_status = true;
        file_icons = true;
        hide_gitignore = false;
        auto_open = {
          on_drop = true;
        };
        hide_hidden = false;
        hide_root = false;
        bold_folder_labels = false;
        auto_fold_dirs = false;
        auto_reveal_entries = true;
        folder_icons = true;
        diagnostic_badges = true;
        git_status_indicator = true;
        dock = "right";
      };
      preview_tabs = {
        enable_preview_from_file_finder = true;
      };
      tabs = {
        show_diagnostics = "all";
        file_icons = true;
        git_status = true;
      };
      tab_bar = {
        show = false;
      };
      pane_split_direction_vertical = "right";
      relative_line_numbers = "enabled";
      gutter = {
        line_numbers = true;
      };
      which_key = {
        enabled = true;
      };
      agent_servers = {
        opencode = {
          default_config_options = {
            model = "opencode/mimo-v2.5-free";
          };
          type = "registry";
        };
        gemini = {
          type = "registry";
        };
      };
      diagnostics = {
        inline = {
          enabled = true;
        };
      };
      document_symbols = "off";
      completion_menu_item_kind = "symbol";
      icon_theme = {
        mode = "dark";
        light = "Catppuccin Latte";
        dark = "Catppuccin Latte";
      };
      vim_mode = true;
      ui_font_size = 16;
      buffer_font_size = 17;
      theme = {
        mode = "dark";
        light = "Catppuccin Mocha";
        dark = "Catppuccin Mocha";
      };
      theme_overrides = {
        "Catppuccin Mocha" = {
          hint = "#89dceb";
          info = "#cba6f7";
          border = "#1e1e2e";
          "border.variant" = "#1e1e2e";
        };
      };
      scrollbar = {
        show = "never";
      };
      cursor_blink = false;
      ui_font_family = "CaskaydiaCove Nerd Font";
      ui_font_weight = 700;
      buffer_font_family = "CaskaydiaCove Nerd Font";
      buffer_font_weight = 900;
      buffer_line_height = "comfortable";
      buffer_font_features = {
        calt = true;
        zero = true;
        cv01 = true;
      };
      file_finder = {
        modal_max_width = "xlarge";
      };
      soft_wrap = "editor_width";
      
      lsp = {
        gopls = {
          initialization_options = {
            staticcheck = true;
            gofumpt = true;
            analyses = {
              nilness = true;
              unusedwrite = true;
              shadow = true;
              useany = true;
            };
            hints = {
              assignVariableTypes = true;
              compositeLiteralFields = true;
              compositeLiteralTypes = true;
              constantValues = true;
              functionTypeParameters = true;
              parameterNames = true;
              rangeVariableTypes = true;
            };
          };
        };
        golangci-lint = {
          initialization_options = {
            command = [
              "golangci-lint"
              "run"
              "--output.json.path"
              "stdout"
              "--show-stats=false"
              "--output.text.path="
            ];
          };
        };
        oxlint = {
          initialization_options = {
            settings = {
              configPath = null;
              run = "onType";
              disableNestedConfig = false;
              fixKind = "safe_fix";
              unusedDisableDirectives = "deny";
            };
          };
        };
        oxfmt = {
          initialization_options = {
            settings = {
              "fmt.configPath" = null;
              run = "onSave";
            };
          };
        };
        tailwindcss-language-server = {
          settings = {
            classFunctions = [ "cva" "cx" ];
            includeLanguages = {
              vue = "html";
            };
            experimental = {
              classRegex = [
                "(?:cls|className|\\w*Classes\\w*)\\s*(?:=|:)\\s*['\"`]([^'\"`]*)['\"`]"
                "\\.className\\s*\\+?=\\s*['\"]([^'\"]*)['\"]"
                "\\.setAttribute(?:NS)?\\([^)]*?['\"]class['\"],\\s*['\"]([^'\"]*)['\"]"
                "\\.classList\\.(?:add|remove|toggle|contains)\\(([^)]*)\\)"
                "\\.classList\\.replace\\(([^)]*)\\)"
                "\\b\\w*Classes\\w*\\s*=\\s*\\{([\\s\\S]*?)\\}"
                "class=\"([^\"]*)\""
                "class='([^']*)'"
                ":class=\"([^\"]*)\""
                ":class='([^']*)'"
              ];
            };
          };
        };
        vue = {
          settings = {
            "vue.inlayHints.inlineHandlerLeading" = true;
            "vue.inlayHints.missingProps" = true;
            "vue.inlayHints.optionsWrapper" = true;
            "vue.inlayHints.vBindShorthand" = true;
          };
        };
      };

      languages = {
        Go = {
          language_servers = [ "gopls" "golangci-lint" ];
          inlay_hints = {
            enabled = true;
          };
        };
        TypeScript = {
          language_servers = [
            "!typescript-language-server"
            "angular"
            "vtsls"
          ];
          format_on_save = "on";
          prettier = {
            allowed = false;
          };
          formatter = [
            {
              language_server = {
                name = "oxfmt";
              };
            }
          ];
        };
        JavaScript = {
          format_on_save = "on";
          prettier = {
            allowed = false;
          };
          formatter = [
            {
              language_server = {
                name = "oxc";
              };
            }
            {
              code_action = "source.fixAll.oxc";
            }
          ];
        };
        "Vue.js" = {
          language_servers = [
            "vue-language-server"
            "!typescript-language-server"
            "tailwindcss-language-server"
            "vtsls"
          ];
        };
        HTML = {
          language_servers = [ "angular" "..." ];
        };
      };
    };

    userKeymaps = [
      {
        context = "Editor";
        bindings = {
          "ctrl-right" = "workspace::ActivatePaneRight";
          "ctrl-left" = "workspace::ActivatePaneLeft";
          "ctrl-alt-right" = "workspace::SwapPaneRight";
          "ctrl-alt-left" = "workspace::SwapPaneLeft";
        };
      }
      {
        bindings = {
          "ctrl-alt-g" = [
            "agent::NewExternalAgentThread"
            { agent = { custom = { name = "gemini"; }; }; }
          ];
        };
      }
      {
        context = "VimControl && !menu";
        bindings = {
          "space c r" = "editor::Rename";
          "space c a" = "editor::ToggleCodeActions";
          "space t" = "terminal_panel::ToggleFocus";
          "space c d" = "diagnostics::ToggleWarnings";
          "[ d" = "editor::GoToPrevDiagnostic";
          "] d" = "editor::GoToDiagnostic";
          "space e" = "project_panel::ToggleFocus";
        };
        unbind = {
          "g r n" = "editor::Rename";
          "g ." = "editor::ToggleCodeActions";
        };
      }
      {
        context = "Editor";
        bindings = {
          "space g d" = "editor::ToggleSplitDiff";
        };
      }
      {
        bindings = {
          "space" = "git_panel::OpenMenu";
        };
      }
      {
        context = "Workspace";
        bindings = {
          "space g g" = "git_panel::ToggleFocus";
        };
      }
      {
        context = "Workspace";
        unbind = {
          "ctrl-shift-g" = "git_panel::ToggleFocus";
        };
      }
      {
        context = "Workspace";
        bindings = {
          "space g c" = "git_panel::Close";
        };
      }
      {
        context = "Workspace";
        bindings = {
          "shift-space e" = "workspace::ToggleRightDock";
        };
      }
      {
        context = "Workspace";
        unbind = {
          "ctrl-alt-b" = "workspace::ToggleRightDock";
        };
      }
      {
        context = "Workspace";
        bindings = {
          "ctrl-alt-o" = "workspace::NewFile";
        };
      }
      {
        context = "Workspace";
        unbind = {
          "ctrl-n" = "workspace::NewFile";
        };
      }
      {
        context = "!Editor && !Terminal";
        unbind = {
          "space f" = "file_finder::Toggle";
        };
      }
      {
        context = "(vim_mode == helix_normal || vim_mode == helix_select) && !menu";
        unbind = {
          "space f" = "file_finder::Toggle";
        };
      }
      {
        context = "!Editor && !Terminal";
        bindings = {
          "space space" = "file_finder::Toggle";
        };
      }
      {
        context = "Workspace";
        bindings = {
          "space a i" = "agent::ToggleFocus";
        };
      }
      {
        context = "Workspace";
        unbind = {
          "ctrl-shift-ç" = "agent::ToggleFocus";
        };
      }
      {
        context = "Workspace";
        bindings = {
          "ctrl-`" = "terminal_panel::ToggleFocus";
        };
      }
    ];
  };
}
