# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "latam";
    variant = "nodeadkeys";
  };

  # Configure console keymap
  console.keyMap = "la-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.sudo.wheelNeedsPassword = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."gian" = {
    isNormalUser = true;
    description = "Gian";
    extraGroups = [ "networkmanager" "wheel" "video" "render" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  programs.nix-ld.enable = true;


  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
	experimental-features = [
	   "nix-command"
	   "flakes"	   
	];
};
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.sessionVariables = {
	NIXOS_OZONE_WL = "1";
  };
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     wget
     niri	
     fuzzel
     waybar
     git
     unzip
     gnutar
     p7zip
     neovim
     mako
     alacritty
     kitty
     wl-clipboard
     grim
     slurp
     brightnessctl
     playerctl
     tmux
     ripgrep
     fd
     gcc
     ffmpeg
     poppler
     resvg
     imagemagick
     gnumake
     tree-sitter
     docker
     docker-compose
     python3
     go
     nodejs
     pnpm
     postgresql
     zsh
     lazygit
     yazi
     fzf
     lsd
     starship
     fastfetch
     blender
     obs-studio
     (pkgs.lib.hiPrio (pkgs.writeShellScriptBin "davinci-resolve" ''
       export QT_QPA_PLATFORM=xcb
       export QT_PLUGIN_PATH=""
       export QML2_IMPORT_PATH=""
       export ROC_ENABLE_PRE_VEGA=1
       export RUSTICL_ENABLE=radeonsi
       export DRI_PRIME=1
       
       # If DISPLAY is not set but WAYLAND_DISPLAY is, guess that DISPLAY is :0
       if [ -z "$DISPLAY" ] && [ -n "$WAYLAND_DISPLAY" ]; then
         export DISPLAY=:0
       fi

       exec ${pkgs.davinci-resolve}/bin/davinci-resolve "$@"
     ''))
     xwayland-satellite
     davinci-resolve
     clinfo
     zed-editor-fhs
     opencode
  ];
  
  fonts.packages = with pkgs; [
     nerd-fonts.caskaydia-cove
  ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.niri.enable = true;

  programs.zsh.enable = true;

  virtualisation.docker.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # Enable hardware graphics acceleration and OpenCL support for AMD GPU
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr
      rocmPackages.clr.icd
      mesa.opencl
    ];
  };

  system.stateVersion = "26.05"; # Did you read the comment?

  # Automatically backup conflicting files when Home Manager switches
  home-manager.backupFileExtension = "hm-backup";
}
