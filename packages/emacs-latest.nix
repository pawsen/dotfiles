# packages/emacs-latest.nix
#
# Emacs built from pkgs.unstable (i.e. nixpkgs-unstable),
# with tree-sitter grammars and vterm bundled via emacsWithPackages.

{ pkgs, ... }:

let
  # Provided by your flake overlay:
  #   overlay = final: prev: { unstable = pkgs'; my = self.packages.${system}; ... };
  unstablePkgs = pkgs.unstable;
in
(unstablePkgs.emacsPackagesFor unstablePkgs.emacs-gtk).emacsWithPackages
  (epkgs: with epkgs; [
    treesit-grammars.with-all-grammars
    vterm
    # mu4e  # uncomment if you want it and it's available in this set
  ])

