{ cabal, ekgCore, network, text, vector, wreq }:
cabal.mkDerivation (self: {
  pname = "ekg-bosun";
  version = "1.0.0";
  src = ./.;
  buildDepends = [ ekgCore network text vector wreq ];
})
