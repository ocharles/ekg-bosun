{ mkDerivation, aeson, base, ekg-core, http-client, lens, network
, network-uri, old-locale, stdenv, text, time, unordered-containers
, vector, wreq
}:
mkDerivation {
  pname = "ekg-bosun";
  version = "1.0.3";
  src = ./.;
  buildDepends = [
    aeson base ekg-core http-client lens network network-uri old-locale
    text time unordered-containers vector wreq
  ];
  homepage = "http://github.com/ocharles/ekg-bosun";
  description = "Send ekg metrics to a Bosun instance";
  license = stdenv.lib.licenses.bsd3;
}
