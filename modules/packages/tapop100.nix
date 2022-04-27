{ lib
, python3
, fetchFromGitHub
}:
python3.pkgs.buildPythonPackage {
  pname = "TapoP100";
  version = "unstable-2022-04-04";

  src = fetchFromGitHub {
    owner = "fishbigger";
    repo = "TapoP100";
    rev = "4e0458ff300102f630d953ebb463bfd7dff05f7a";
    sha256 = "0lnlkza5v5d1xdc1irvj5zln3yc7aqy7cr9d0qxd3w7wd5ryiaip";
  };

  # Pinning without a real need
  patchPhase = ''
    substituteInPlace setup.py \
      --replace 'requests==2.24.0' 'requests' \
      --replace 'pycryptodome==3.9.8' 'pycryptodome'
  '';

  propagatedBuildInputs = with python3.pkgs; [
    (callPackage ./pkcs7.nix {})
    pycryptodome
    requests
  ];

  meta = with lib; {
    description = "Controller for Tp-link Tapo P100 plugs, P105 plugs and L510E bulbs";
    homepage    = "https://github.com/fishbigger/TapoP100";
    license     = licenses.mit;
    maintainers =  with maintainers; [ seqizz ];
  };
}

