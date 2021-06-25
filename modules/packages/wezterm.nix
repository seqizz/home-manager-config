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
    # rev = "2e7dc70eaf1b13fb19123e5ae606b4e745114c62";
    rev = "618f77f2c65d77720613a06b1f0a6be6af12d340";
    fetchSubmodules = true;
    sha256 = "0qj6dyrswysby2z0g8ag0mvsgl8gf68sl5iymzif8mknl05q9phg";
  };
  cargoSha256 = "16s46qc83kkg8bp0c446iabk1bcdjwda2i3shnirp8pq2a0b3569";

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
