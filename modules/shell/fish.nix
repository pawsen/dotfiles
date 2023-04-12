{ config, options, pkgs, lib, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.fish;
    configDir = config.dotfiles.configDir;
in {
  options.modules.shell.fish = with types; {
    enable = mkBoolOpt false;
    shellAbbrs = mkOption {
      type = attrsOf str;
      default = { };
      example = {
        l = "less";
        gco = "git checkout";
      };
    };
    shellAliases = mkOption {
      type = with types; attrsOf str;
      default = { };
      example = literalExpression ''
          {
            g = "git";
            "..." = "cd ../..";
          }
        '';
      description = ''
          An attribute set that maps aliases (the top level attribute names
          in this option) to command strings or directly to build outputs.
        '';
    };
  };

  config = mkIf cfg.enable {

    # I manage fish configuration and plugins with home manager, but to enable
    # vendor fish completions provided by Nixpkgs it also needs to be enabled here
    programs = {
      fish.enable = true;
      fish.promptInit = ''
          # When entering a nix run environment, the shell stays the same. does not work for nix develop.
          # Uncommented until I get confident with nix run
          # any-nix-shell fish --info-right | source
        '';
    };

    home-manager.users.${config.user.name}.programs.fish = {
      enable = true;
      plugins = [
        {
          name = "z";
          src = pkgs.fetchFromGitHub {
            owner = "jethrokuan";
            repo = "z";
            rev = "85f863f20f24faf675827fb00f3a4e15c7838d76";
            sha256 = "sha256-+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
          };
        }
      ];
      shellAbbrs =
        {
          et = "emacsclient -nw";  #  pgrep emacs && emacsclient -nw "$@" || emacs -nw "$@"
          ef = "emacsclient -cn";  #  pgrep emacs && emacsclient -c -n "$@" || emacs "$@"
          ta = "tmux attach";
          tl = "tmux ls";
          cat = "bat";
        } // cfg.shellAbbrs;
      shellAliases =
        {
          xclip = "xclip -selection clipboard";
        } // cfg.shellAliases;
    };

    home.configFile = {
      # Write it recursively so other modules can write files to it
      # XXX when creating the functions/ dir recursive, changes made to
      # individual files are not "discovered" and updated in the nix store / new
      # symlink
      # "fish/functions" = { source = "${configDir}/fish/functions"; recursive = true; };
      "fish/functions/functions.fish".source = "${configDir}/fish/functions/functions.fish";
    };
  };

}
