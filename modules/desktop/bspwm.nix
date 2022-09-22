{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.bspwm;
    configDir = config.dotfiles.configDir;
in {
  options.modules.desktop.bspwm = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    modules.theme.onReload.bspwm = ''
      ${pkgs.bspwm}/bin/bspc wm -r
      source $XDG_CONFIG_HOME/bspwm/bspwmrc
    '';

    environment.systemPackages = with pkgs; [
      lightdm
      dunst
      libnotify
      acpi        # show battery information
      (polybar.override {
        pulseSupport = true;
        nlSupport = true;
      })
      keyutils    # provide keyctl, used for rofi-bwmenu
      bc          # needed by rofi-bluetooth (renamed to bluetoothmenu)
    ];

    programs = {
      light.enable = true;   # chnage backlight
    };
    user.extraGroups = [ "video" ];

    services = {
      picom.enable = true;
      redshift.enable = true;
      xserver = {
        enable = true;
        displayManager = {
          defaultSession = "none+bspwm";
          lightdm.enable = true;
          lightdm.greeters.mini.enable = true;
        };
        windowManager.bspwm.enable = true;
      };
    };

    systemd.user.services."dunst" = {
      enable = true;
      description = "";
      wantedBy = [ "default.target" ];
      serviceConfig.Restart = "always";
      serviceConfig.RestartSec = 2;
      serviceConfig.ExecStart = "${pkgs.dunst}/bin/dunst";
    };

    # keyctl fix,
    # https://discourse.nixos.org/t/keyctl-read-alloc-permission-denied/8667/4
    # links the UID0(@u) to the current session(@s) in the kernel keyring
    # https://mjg59.dreamwidth.org/37333.html
    systemd.user.services."keyctl_fix" = {
      enable = true;
      description = "keyctl fix";
      wantedBy = [ "default.target" ];
      # make keyctl available to the shell
      path = [ pkgs.keyutils ];
      serviceConfig = {
        Type = "oneshot";
        # only set user/group for system units. Newer user units!
        # User = config.user.name;
        # Group = config.user.group;
      };
      script = ''
           command -v keyctl >/dev/null 2>&1 || { echo >&2 "I require keyctl but it's not available."; }
           keyctl link @u @s
           '';
    };

    # link recursively so other modules can link files in their folders
    home.configFile = {
      "sxhkd".source = "${configDir}/sxhkd";
      "bspwm" = {
        source = "${configDir}/bspwm";
        recursive = true;
      };
    };
  };
}
