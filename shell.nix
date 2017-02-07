{ nixpkgs ? import <nixpkgs> {}, compiler ? "default" }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, aeson, base, ekg-core, http-client, lens
      , network, network-uri, old-locale, stdenv, text, time
      , unordered-containers, vector, wreq
      }:
      mkDerivation {
        pname = "ekg-bosun";
        version = "1.0.7";
        src = ./.;
        libraryHaskellDepends = [
          aeson base ekg-core http-client lens network network-uri old-locale
          text time unordered-containers vector wreq
        ];
        homepage = "http://github.com/ocharles/ekg-bosun";
        description = "Send ekg metrics to a Bosun instance";
        license = stdenv.lib.licenses.bsd3;
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  drv = haskellPackages.callPackage f {};

in

  if pkgs.lib.inNixShell then drv.env else drv
