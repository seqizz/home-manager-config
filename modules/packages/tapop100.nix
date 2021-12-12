{ lib
, python3
, fetchFromGitHub
}:
python3.pkgs.buildPythonPackage {
  pname = "TapoP100";
  version = "unstable-2021-08-21";

  src = fetchFromGitHub {
    owner = "fishbigger";
    repo = "TapoP100";
    rev = "345eacccba926cd47fc751eca1b338480a3defe1";
    sha256 = "1w9qyi2kqcvdhdiijwj5qc61w5n9ngl9yi4i5waaarjiwiirrlcg";
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

