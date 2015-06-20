let
  pkgs = import <nixpkgs> {};
  haskellPackages = pkgs.haskell-ng.packages.ghc7101.override {
    overrides = self: super: {
      ekgBosun = self.callPackage ./. {};
    };
  };

in haskellPackages.ekgBosun.env
