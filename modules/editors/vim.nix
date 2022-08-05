# When I'm stuck in the terminal or don't have access to Emacs, (neo)vim is my
# go-to. I am a vimmer at heart, after all.

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.editors.vim;
    configDir = config.dotfiles.configDir;
in {
  options.modules.editors.vim = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      editorconfig-core-c
      # for coc-nvim
      nodejs yarn
      # formatting with clang
      clang-tools
      (unstable.neovim.override {
        vimAlias = true;
        viAlias = true;
        configure = {
          customRC = builtins.readFile "${configDir}/vim/vimrc";
          packages.myPlugins = with pkgs.vimPlugins; {
            start = [
              vim-surround # Shortcuts for setting () {} etc.
              coc-nvim coc-git coc-highlight coc-python coc-rls coc-vetur coc-vimtex coc-yaml coc-html coc-json # auto completion
              vim-nix # nix highlight
              vimtex # latex stuff
              fzf-vim # fuzzy finder through vim
              nerdtree # file structure inside nvim
              rainbow # Color parenthesis
              vim-clang-format # format c and friends
              vim-operator-user # map plugins to keybinds
            ];
            opt = [];
          };
        };
      })
    ];

    # This is for non-neovim, so it loads my nvim config
    # env.VIMINIT = "let \\$MYVIMRC='\\$XDG_CONFIG_HOME/nvim/init.vim' | source \\$MYVIMRC";

  };
}
