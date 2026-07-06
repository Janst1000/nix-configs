# ~/nix-configurations/home.nix
{ config, pkgs, ... }:

{
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    htop
    hyprmon
  ];

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 48;
    gtk.enable = true;
    x11.enable = true;
    x11.defaultCursor = "Bibata-Modern-Ice";
  };

  gtk = {
    enable = true;
    theme = {
      name = "Nordic";
      package = pkgs.nordic;
    };
    cursorTheme.name = "Bibata-Modern-Ice";
    cursorTheme.size = 24;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Janst1000";
      user.email = "janst1000@gmail.com";
    };
  };

  programs.kitty = {
    enable = true;
    themeFile = "OneHalfDark";
    extraConfig = ''
      font meslo-lgs-nf:size=12;
    '';
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    withPython3 = false;
    withRuby = false;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    dotDir = "/home/jan/.config/zsh";
    shellAliases = {
      nixcfgswitch = "sudo nixos-rebuild switch --flake ~/nix-configurations#nixos";
      nixcfgedit = "sudo nvim ~/nix-configurations/configuration.nix";
    };
    profileExtra = ''
      setopt interactivecomments
    '';
    initContent = ''
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source /etc/nixos/p10k/.p10k.zsh
      autoload -U colors
      colors
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
      export HYPRLAND_CONFIG=~/.config/hypr/monitors.conf
    '';
  };

  programs.wlogout = {
    enable = true;
    layout = [
      { label = "lock"; action = "hyprlock -q"; text = "Lock"; keybind = "l"; }
      { label = "hibernate"; action = "systemctl hibernate"; text = "Hibernate"; keybind = "h"; }
      { label = "logout"; action = "loginctl terminate-user $USER"; text = "Logout"; keybind = "e"; }
      { label = "shutdown"; action = "systemctl poweroff"; text = "Shutdown"; keybind = "s"; }
      { label = "suspend"; action = "systemctl suspend & hyprlock -q"; text = "Suspend"; keybind = "u"; }
      { label = "reboot"; action = "systemctl reboot"; text = "Reboot"; keybind = "r"; }
    ];
    style = ''
      * { background-image: none; box-shadow: none; }
      window { background-color: rgba(12, 12, 12, 0.9); }
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
      #lock { background-image: image(url("/home/jan/.nix-profile/share/wlogout/icons/lock.png")); }
      #logout { background-image: image(url("/home/jan/.nix-profile/share/wlogout/icons/logout.png")); }
      #suspend { background-image: image(url("/home/jan/.nix-profile/share/wlogout/icons/suspend.png")); }
      #hibernate { background-image: image(url("/home/jan/.nix-profile/share/wlogout/icons/hibernate.png")); }
      #shutdown { background-image: image(url("/home/jan/.nix-profile/share/wlogout/icons/shutdown.png")); }
      #reboot { background-image: image(url("/home/jan/.nix-profile/share/wlogout/icons/reboot.png")); }
    '';
  };

  # ── Hyprpaper ──────────────────────────────────────────────
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "~/Pictures/wallpapers/wallhaven-ex136k.jpg" ];
      wallpaper = [
        { monitor = "eDP-1"; path = "~/Pictures/wallpapers/wallhaven-ex136k.jpg"; }
        { monitor = ""; path = "~/Pictures/wallpapers/wallhaven-ex136k.jpg"; }  # Fallback für andere Monitore
      ];
    };
  };

  # ── Hypridle ───────────────────────────────────────────────
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        { timeout = 150; "on-timeout" = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10"; "on-resume" = "${pkgs.brightnessctl}/bin/brightnessctl -r"; }
        { timeout = 150; "on-timeout" = "${pkgs.brightnessctl}/bin/brightnessctl -sd rgb:kbd_backlight set 0"; "on-resume" = "${pkgs.brightnessctl}/bin/brightnessctl -rd rgb:kbd_backlight"; }
        { timeout = 300; "on-timeout" = "loginctl lock-session"; }
        { timeout = 330; "on-timeout" = "hyprctl dispatch dpms off"; "on-resume" = "hyprctl dispatch dpms on"; }
        { timeout = 1800; "on-timeout" = "systemctl suspend"; }
      ];
    };
  };

  # ── Hyprland itself ────────────────────────────────────────
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;         # Hyprland kommt aus programs.hyprland (configuration.nix)
    portalPackage = null;   # xdg-desktop-portal-hyprland ebenso
    systemd.enable = false; # UWSM übernimmt die Session, nicht Home-Manager
    extraConfig = ''
      source = ~/.config/hypr/monitors.conf
    '';
    settings = {
      "$mainMod" = "SUPER";

      xwayland.force_zero_scaling = true;

      env = [
        "GDK_SCALE,2"
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,Bibata-Modern-Ice"
        "HYPRCURSOR_THEME,Bibata-Modern-Ice"
        "HYPRCURSOR_SIZE,24"
      ];

      "exec-once" = [
        "bash ~/.config/hypr/start.sh"
        "lxqt-policykit-agent"
        "nextcloud"
      ];
      # hypridle & hyprpaper absichtlich raus -- laufen jetzt als systemd-Services (siehe oben)

      cursor.no_hardware_cursors = false;

      input = {
        kb_layout = "de";
        follow_mouse = 1;
        sensitivity = 0.1;
        touchpad.natural_scroll = true;
      };

      general = {
        gaps_in = 5;
        gaps_out = 7;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(bc42f5ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
        allow_tearing = false;
      };

      decoration = {
        rounding = 10;
        active_opacity = 0.9;
        inactive_opacity = 0.85;
        fullscreen_opacity = 1.0;
        blur = {
          enabled = true;
          special = true;
          xray = true;
          size = 6;
          passes = 1;
          ignore_opacity = true;
          new_optimizations = true;
        };
      };

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 5, myBezier"
          "windowsOut, 1, 5, default, popin 80%"
          "border, 1, 5, default"
          "borderangle, 1, 5, default"
          "fade, 1, 5, default"
          "workspaces, 1, 5, default"
        ];
      };

      dwindle.preserve_split = true;

      gesture = [
        "3, horizontal, workspace"
        "3, up, mod: SUPER, scale: 1.5, fullscreen"
      ];

      misc.force_default_wallpaper = 0;

      windowrule = [
        "opacity 1.0 1.0, match:class ^(Firefox)$"
        "border_color rgb(FF0000) rgb(880808), match:fullscreen 1"
      ];

      bind = [
        "$mainMod, Q, exec, kitty"
        "$mainMod, C, killactive"
        "$mainMod, M, exit"
        "$mainMod, E, exec, thunar"
        "$mainMod, V, togglefloating"
        "$mainMod, R, exec, rofi -show drun -show-icons"
        "$mainMod, P, pseudo"
        "$mainMod, J, layoutmsg, togglesplit"
        "$mainMod, F, fullscreen"
        "$mainMod SHIFT, F, fullscreenstate"
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
        "$mainMod, l, exec, wlogout"
        ", Print, exec, grim -g \"$(slurp)\""
        "$mainMod, Print, exec, grim -g \"$(slurp -d)\" - | wl-copy"
        "$mainMod, o, exec, hyprctl setprop active opaque toggle"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      bindle = [
        ", XF86AudioRaiseVolume, exec, pamixer -i 5"
        ", XF86AudioLowerVolume, exec, pamixer -d 5"
        ", XF86MonBrightnessUp, exec, brightnessctl set +10%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"
        ", XF86Search, exec, launchpad"
      ];

      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];
    };
  };
}