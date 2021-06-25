{ stdenv, fetchFromGitHub, pulseaudioFull }:

stdenv.mkDerivation {
  name = "paoutput";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "davjgardner";
    repo = "paoutput";
    rev = "223a6af";
    sha256 = "1f1cmb9wchxr3g9hdswzlzr11wbqy58cqz56dryp8wpw3brirb02";
  };

  buildInputs = [ pulseaudioFull ];

  installPhase = ''
    mkdir -p $out/bin
    cp paoutput $out/bin
  '';
}
