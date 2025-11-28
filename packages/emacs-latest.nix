# packages/emacs-latest.nix
#
# Emacs built from pkgs.unstable (i.e. nixpkgs-unstable),
# with tree-sitter grammars and vterm bundled via emacsWithPackages.
#
# In the flake dir, do
# nix profile install \
#        --override-input nixpkgs-unstable github:NixOS/nixpkgs \
#        .#emacs-latest


{ pkgs, ... }:

let
  unstablePkgs = pkgs.unstable;
in
(unstablePkgs.emacsPackagesFor unstablePkgs.emacs-gtk).emacsWithPackages
  (epkgs: with epkgs; [
    treesit-grammars.with-all-grammars
    vterm
    # mu4e
  ])

