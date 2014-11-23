let
  pkgs = import <nixpkgs> {};
  haskellPackages = pkgs.haskellPackages.override {
    extension = self: super: {
      ekgBosun = self.callPackage ./. {};
    };
  };

in pkgs.myEnvFun {
     name = haskellPackages.ekgBosun.name;
     buildInputs = [
       pkgs.curl
       (haskellPackages.ghcWithPackages (hs: ([
         hs.cabalInstall
         hs.hscolour
       ] ++ hs.ekgBosun.propagatedNativeBuildInputs)))
     ];
   }
