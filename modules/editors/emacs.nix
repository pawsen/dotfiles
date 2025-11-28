# Emacs is my main driver. I'm the author of Doom Emacs
# https://github.com/hlissner/doom-emacs. This module sets it up to meet my
# particular Doomy needs.

{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let cfg = config.modules.editors.emacs;
    configDir = config.dotfiles.configDir;

    emacs = with pkgs; (emacsPackagesFor emacs29-gtk3).emacsWithPackages
      (epkgs: with epkgs; [
         treesit-grammars.with-all-grammars
         vterm
         # mu4e
      ]);

in {
  options.modules.editors.emacs = {
    enable = mkBoolOpt false;
    daemon = mkBoolOpt false;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      nixpkgs.overlays = [ inputs.emacs-overlay.overlay ];

      user.packages = with pkgs; [
        ## Emacs itself
        binutils            # native-comp needs 'as', provided by this
        emacs               # HEAD + native-comp

        ## Doom dependencies
        git
        (ripgrep.override {withPCRE2 = true;})
        gnutls              # for TLS connectivity

        ## Optional dependencies
        fd                  # faster projectile indexing
        # XXX: pinentry-emacs somehow breaks rage when using ssh-keys
        # pinentry-emacs also provides a pinentry binary which rage uses
        # (mkIf (config.programs.gnupg.agent.enable)
        #   pinentry-emacs    # in-emacs gnupg prompts
        # )
        zstd                # for undo-fu-session/undo-tree compression

        ## Module dependencies
        # :email mu4e
        #mu
        #isync
        # : tools dired
        # specific for dired/dirvish
        imagemagick         # for font preview
        vips                # vipsthumbnail for image preview
        poppler             # for pdf preview
        ffmpegthumbnailer   # for video preview
        mediainfo           # for audio/video metadata generation,
        # epub-thumbnailer    # for epubs XXX introduced in 24.11, I run 24.05...
        # p7zip, port of 7zip, originally windows only. For dirvish archive file preview
        (p7zip.override {enableUnfree = true;})

        # :checkers spell
        (aspellWithDicts (ds: with ds; [ en en-computers en-science da ]))
        # :tools editorconfig
        editorconfig-core-c # per-project style config
        # :tools lookup & :lang org +roam
        sqlite
        # :lang latex & :lang org (latex previews)
        texlive.combined.scheme-medium
        gnuplot
        maim                # for org-download-clipboard
        # :lang beancount
        # beancount
        # unstable.fava  # HACK Momentarily broken on nixos-unstable
        # :lang rust
        rustfmt
        rust-analyzer

        ## lsp
        pyright  # python
        # HTML/CSS/JSON/ESLint language servers extracted from vscode.
        nodePackages.vscode-langservers-extracted
        nodePackages.bash-language-server  # sh
        ## formatters
        html-tidy             # html
        jsbeautifier          # html/js/css
        nodePackages.stylelint# css
        shellcheck            # sh syntax
        shfmt                 # sh
        nixfmt                # nix
        libxml2               # data
        dockfmt               # docker

      ];
      env.PATH = [ "$XDG_CONFIG_HOME/emacs/bin" ];

      modules.shell.zsh.rcFiles = [ "${configDir}/emacs/aliases.zsh" ];
      fonts.packages = with pkgs; [
        # list of nerdfonts that can be included
        # https://github.com/NixOS/nixpkgs/blob/nixos-23.05/pkgs/data/fonts/nerdfonts/shas.nix
        # (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" "JetBrainsMono" ]; })
        (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
      ];
    }
    # enable emacs daemon
    (mkIf cfg.daemon {
      services.emacs.package = emacs;
      services.emacs.enable = true;
      # services.emacs.defaultEditor = true;
    })
  ]);
}
