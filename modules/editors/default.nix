{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.editors;
in {
  options.modules.editors = {
    default = mkOpt types.str "vim";
  };

  config = mkIf (cfg.default != null) {
    # This is the correct way to set a env var. But hlissner made a shortcut used below
    # environment.variables.EDITOR = cfg.default;
    env.EDITOR = cfg.default;
  };
}
