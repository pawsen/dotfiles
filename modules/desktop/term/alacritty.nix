{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.term.alacritty;
    configDir = config.dotfiles.configDir;
in {
  options.modules.desktop.term.alacritty = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      unstable.alacritty
    ];

    home.configFile = {
      "alacritty/alacritty.yml".source = "${configDir}/alacritty/alacritty.yml";
    };

  };
}
