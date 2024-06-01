# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

##############################
# TODO: Set GDK Theme to darkmode :(

{ config, pkgs, ... }:

let
  user = "jan";
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # NTFS support
  boot.supportedFilesystems = ["ntfs"];

  # XDG Portals
  xdg = {
    autostart.enable = true;
    portal = {
    enable = true;
    extraPortals = [
        pkgs.xdg-desktop-portal
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    layout = "de";
    xkbVariant = "";
#    displayManager.sessionCommands = ''
#      export GTK_THEME=Breeze-Dark
#    '';
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    videoDrivers = ["nvidia"];
  };



  # Configure console keymap
  console.keyMap = "de";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jan = {
    isNormalUser = true;
    description = "Jan";
    extraGroups = [ "networkmanager" "wheel" "docker" "tss"];
    packages = with pkgs; [];
  };




  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allowing Insecure Electron for Obsidian
  #{
  #  nixpkgs.config.permittedInsecurePackages = [
  #    "electron-25.9.0"
  #  ];
  #};
 
 
  nixpkgs.config.packageOverrides = pkgs: with pkgs; {
    unstable = import unstableTarball {
      config = config.nixpkgs.config;
      #config.allowUnfree = true;
    };
  };

  # Allow Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes"];  

# List packages installed in system profile. To search, run:
  # $ nix search wget
  
  environment.systemPackages = with pkgs; [
    neovim# Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    waybar
    dunst
    libnotify
    kitty
    rofi-wayland
    nerdfonts
    firefox
    zsh
    zplug
    zsh-powerlevel10k
    meslo-lgs-nf
    thefuck
    git
    swww
    networkmanagerapplet
    pamixer
    brightnessctl
    libreoffice-qt
    hunspell
    hunspellDicts.de_DE
    hunspellDicts.en_US
    vscode # set titlebar to custom on wayland
    grim
    slurp
    wl-clipboard
    pkgs.libsForQt5.qt5ct
    breeze-icons
    pywal
    fastfetch
    unstable.appimage-run
    unstable.appimagekit
    gcc
    imv
    webcord
    mpd
    pavucontrol
    xwaylandvideobridge
    zoom-us
    thunderbird
    #immersed-vr
    nvidia-offload
    glxinfo
    nvtop
    powertop
    unstable.obsidian
    wl-clipboard
    openssl
    jetbrains.idea-ultimate
    unzip
    tpm2-tools
    jdk21
    hyprlock
  ];

  virtualisation.docker.enable = true;

  services.tlp.settings = {
    INTEL_GPU_MIN_FREQ_ON_AC = 500;
    INTEL_GPU_MIN_FREQ_ON_BAT = 500;
  };

  # Custom Rofi Theme
  #customRofiTheme = /path/to/your/theme.rasi;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };


  # swaylock
  # swaylock needs this otherwise password fails even if correct
    security.pam.services.hyprlock = {};

  # TPM2 support
  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true;  # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  security.tpm2.tctiEnvironment.enable = true;  # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables

  # Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    
  };

  programs.waybar.enable = true;

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  environment.variables = {
    # Set the Qt platform theme to enable dark mode for Qt applications
    QT_QPA_PLATFORMTHEME = "qt5ct";

#    # Set the GTK theme to Breeze-Dark
#    GTK_THEME = "Breeze-Dark";

    # Set XDG_SESSION_TYPE to "wayland" if using Wayland
    XDG_SESSION_TYPE = "wayland";
  };
  


  environment.etc = {
    "xdg/gtk-2.0/gtkrc".text = "gtk-error-bell=0";
    "xdg/gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-theme=Breeze-Dark
    '';
    "xdg/gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-theme=Breeze-Dark
    '';
  };


  hardware = {
    opengl.enable = true;
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      
      prime = {
         offload = {
           enable = true;
           enableOffloadCmd = true;
         };
      #sync.enable = true;
      # Setting PCIE bus ID
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      };
    };
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    enableRedistributableFirmware = true;
  };

  services.blueman.enable = true;
  
  # Battery Life
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;
  powerManagement.powertop.enable = true;


  fonts = {
  packages = with pkgs; [
      font-awesome
      meslo-lgs-nf
      orbitron
    ];
  };

  # zsh
  programs.zsh = {
    enable = true;
    histSize = 10000;
    histFile = "$config.xdg.dataHome/zsh/history";
  };
  users.defaultUserShell = pkgs.zsh;

  programs.thunar.enable =true;

  # Printing with CUPS
  services.printing.enable = true;


  # Sound
  sound.enable = true;
  sound.mediaKeys = {
    enable = true;
    volumeStep = "5%";
  };
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };


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
  system.stateVersion = "23.11"; # Did you read the comment?

  # Home-Manager
  home-manager.users.jan = {
    home.stateVersion = "23.11";
    home.packages = with pkgs ; [ 
      htop
    ];
    gtk = {
      enable = true;
      theme = {
        name = "Catppuccin-Macchiato-Compact-Blue-Dark";
        package = pkgs.catppuccin-gtk.override {
          accents = [ "blue" ];
          size = "compact";
          tweaks = [ "rimless" "black" ];
          variant = "macchiato";
        };
      };
    };


    programs.git = {
      enable = true;
      userName = "Janst1000";
      userEmail = "janst1000@gmail.com";
      #safeDirectory= "/etc/nixos";
    };

    programs.kitty = {
      enable = true;
      #theme = "Catppuccin-Macchiato";
      theme = "One Half Dark";
      extraConfig = ''
        font meslo-lgs-nf:size=12;
      '';
    };

    programs.neovim = {
      enable = true;
      vimAlias = true;

    };


#    programs.vscode = {
#      enable = true;
#      userSettings = { "window.titleBarStyle" = "custom"; };
#    };
    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      dotDir = ".config/zsh";

      shellAliases = {
        nixcfgswitch = "sudo nixos-rebuild switch";
        nixcfgedit = "sudo nvim ~/nix-configurations/configuration.nix";
      };

      profileExtra= ''
        setop interactivecomments
      '';

      initExtra = ''
# ##include p10k config manually. Home Manager cannot set and save it
# ##it was moved to /etc/nixos/p10k
source /etc/nixos/p10k/.p10k.zsh
# Theming Section
autoload -U colors
colors
      '';
      zplug = {
        enable = true;
        plugins = [
          { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1]; }
        # Install with additional options #refer to zplug readme
        ];
      };
    };
    programs.wlogout = {
      enable = true;
      layout = [
        {
            "label" = "lock";
            "action" = "hyprlock -q";
            "text" = "Lock";
            "keybind" = "l";
        }
        {
            "label" = "hibernate";
            "action" = "systemctl hibernate";
            "text" = "Hibernate";
            "keybind" = "h";
        }
        {
            "label" = "logout";
            "action" = "loginctl terminate-user $USER";
            "text" = "Logout";
            "keybind" = "e";
        }
        {
            "label" = "shutdown";
            "action" = "systemctl poweroff";
            "text" = "Shutdown";
            "keybind" = "s";
        }
        {
            "label" = "suspend";
            "action" = "systemctl suspend & hyprlock -q";
            "text" = "Suspend";
            "keybind" = "u";
        }
        {
            "label" = "reboot";
            "action" = "systemctl reboot";
            "text" = "Reboot";
            "keybind" = "r";
        }
      ];
      style = ''
      * {
        background-image: none;
        box-shadow: none;
      }

      window {
        background-color: rgba(12, 12, 12, 0.9);
      }

      button {
          border-radius: 0;
          border-color: black;
          color: #FFFFFF;
        background-color: #1E1E1E;
        border-style: solid;
        border-width: 1px;
        background-repeat: no-repeat;
        background-position: center;
        background-size: 25%;
      }

      button:focus, button:active, button:hover {
        background-color: #3700B3;
        outline-style: none;
      }

      #lock {
          background-image: image(url("/home/jan/.nix-profile/share/wlogout/icons/lock.png"), url("/home/jan/.nix-profile/share/wlogout/icons/lock.png"));
      }

      #logout {
          background-image: image(url("/home/jan/.nix-profile/share/wlogout/icons/logout.png"), url("/home/jan/.nix-profile/share/wlogout/icons/logout.png"));
      }

      #suspend {
          background-image: image(url("/home/jan/.nix-profile/share/wlogout/icons/suspend.png"), url("/home/jan/.nix-profile/share/wlogout/icons/suspend.png"));
      }

      #hibernate {
          background-image: image(url("/home/jan/.nix-profile/share/wlogout/icons/hibernate.png"), url("/home/jan/.nix-profile/share/wlogout/icons/hibernate.png"));
      }

      #shutdown {
          background-image: image(url("/home/jan/.nix-profile/share/wlogout/icons/shutdown.png"), url("/home/jan/.nix-profile/share/wlogout/icons/shutdown.png"));
      }

      #reboot {
          background-image: image(url("/home/jan/.nix-profile/share/wlogout/icons/reboot.png"), url("/home/jan/.nix-profile/share/wlogout/icons/reboot.png"));
      }

      '';
    };

  }; 
}
