{ stdenv
, rustPlatform
, makeRustPlatform
, lib
, fetchFromGitHub
, pkgconfig
, fontconfig
, python3
, openssl
, openssh
, perl
, dbus
, libX11
, xcbutil
, libxcb
, ncurses
, xcbutilkeysyms
, xcbutilimage
, xcbutilrenderutil
, xcbutilwm # contains xcb-ewmh among others
, libxkbcommon
, libglvnd # libEGL.so.1
, egl-wayland
, wayland
, libGLU
, libGL
, freetype
, zlib
, rust-bin  # Comes from https://github.com/oxalica/rust-overlay
}:
let
  runtimeDeps = [
    libX11
    xcbutil
    libxcb
    xcbutilkeysyms
    xcbutilwm
    xcbutilimage
    xcbutilrenderutil
    libxkbcommon
    dbus
    libglvnd
    zlib
    egl-wayland
    wayland
    libGLU
    libGL
    fontconfig
    freetype
    openssl
  ];
in
rustPlatform.buildRustPackage {
  name = "wezterm";
  src = fetchFromGitHub {
    owner = "wez";
    repo = "wezterm";
    rev = "a0b8d2196a260726eca28b32fecaeb87420851ec";
    fetchSubmodules = true;
    sha256 = "09lp7ck7bwhjl36ksl0jq8bgwn91y7madfrbzan0l6hb3137vfjw";
  };
  # cargoSha256 = "0000000000000000000000000000000000000000000000000000";
  cargoSha256 = "0fzxs6dfpq5k3s90y6b821qr0qvwpjifssdw6wabnk4b5l1mhhp5";

  nativeBuildInputs = [
    pkgconfig
    python3
    perl
    ncurses
    rust-bin.nightly.latest.default
  ];

  doCheck = false;

  outputs = [ "out" "terminfo" ];

  buildInputs = runtimeDeps;

  postPatch = ''
    echo "2022-g1" > .tag
    sed -i '1i cargo-features = ["edition2021"]' procinfo/Cargo.toml
  '';

  preFixup = lib.optionalString stdenv.isLinux ''
    for artifact in wezterm wezterm-gui wezterm-mux-server strip-ansi-escapes; do
      patchelf --set-rpath "${lib.makeLibraryPath runtimeDeps}" $out/bin/$artifact
    done
  '' + lib.optionalString stdenv.isDarwin ''
    mkdir -p "$out/Applications"
    OUT_APP="$out/Applications/WezTerm.app"
    cp -r assets/macos/WezTerm.app "$OUT_APP"
    rm $OUT_APP/*.dylib
    cp -r assets/shell-integration/* "$OUT_APP"
    ln -s $out/bin/{wezterm,wezterm-mux-server,wezterm-gui,strip-ansi-escapes} "$OUT_APP"
  '';

  postInstall = ''
    mkdir -p $terminfo/share/terminfo/w $out/nix-support
    tic -x -o $terminfo/share/terminfo termwiz/data/wezterm.terminfo
    echo "$terminfo" >> $out/nix-support/propagated-user-env-packages
  '';

  # prevent further changes to the RPATH
  dontPatchELF = true;

  meta = with lib; {
    description = "A GPU-accelerated cross-platform terminal emulator and multiplexer written by @wez and implemented in Rust";
    homepage = "https://wezfurlong.org/wezterm";
    license = licenses.mit;
    maintainers = with maintainers; [ seqizz ];
    platforms = platforms.unix;
  };
}
