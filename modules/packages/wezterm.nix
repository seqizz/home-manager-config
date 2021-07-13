{ stdenv
, rustPlatform
, makeRustPlatform
, lib
, fetchFromGitHub
, pkgconfig
, fontconfig
, python3
, openssl
, perl
, dbus
, libX11
, xcbutil
, libxcb
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
, fenix ? import (builtins.fetchTarball https://github.com/figsoda/fenix/archive/ba0167976a65957ef1d4e569e39e89f77e53f3e3.tar.gz )
, fenixpkgs ?  import <nixpkgs> { overlays = [ fenix ]; }
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
# rustPlatform.buildRustPackage {
(makeRustPlatform {
          inherit (fenixpkgs.rust-nightly.minimal) cargo rustc;
        }).buildRustPackage {
  name = "wezterm";
  src = fetchFromGitHub {
    owner = "wez";
    repo = "wezterm";
    # rev = "618f77f2c65d77720613a06b1f0a6be6af12d340";
    rev = "b4c4c856833877af78c4ad675bcd3c8c583c2497";
    fetchSubmodules = true;
    sha256 = "054zn499r0csz68l71bsgskxn3df8idijs1w3vgkwimqv6rc3ni2";
  };
  cargoSha256 = "1pb9h6l31cdsf3ga1gmzvm3wq5l394jlmp9i6rd25ap76jzs5ams";

  nativeBuildInputs = [
    pkgconfig
    python3
    perl
    fenixpkgs.rust-nightly.default.toolchain
  ];

  buildInputs = runtimeDeps;

  postPatch = ''
    echo "2021-g1" > .tag
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
