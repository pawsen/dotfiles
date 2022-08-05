{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.gnome;
    configDir = config.dotfiles.configDir;
in {
  options.modules.desktop.gnome = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
    lightdm
    ];

    services = {
      redshift.enable = true;
      xserver = {
        enable = true;
        displayManager = {
          lightdm.enable = true;
          #gdm.enable = true;

        };
        desktopManager.gnome.enable = true;
      };
    };

  };
}
