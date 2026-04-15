{ lib
, stdenv
, fetchFromGitHub
, cmake
, extra-cmake-modules
, pkg-config

, qtbase
, kcoreaddons
, kdbusaddons
, ki18n
, kwindowsystem

, xorg
}:

stdenv.mkDerivation rec {
  pname = "xembed-sni-proxy";
  version = "git";

  src = fetchFromGitHub {
    owner = "davidedmundson";
    repo = "xembed-sni-proxy";
    rev = "64fa7e351737dac56c1e0c884bba86ed73c4cccc";
    sha256 = lib.fakeSha256;
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    pkg-config
  ];

  buildInputs = [
    qtbase
    kcoreaddons
    kdbusaddons
    ki18n
    kwindowsystem

    xorg.libxcb
    xorg.xcbutil
    xorg.xcbutil-image
    xorg.xcbutil-keysyms
    xorg.xcbutil-wm
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  meta = with lib; {
    description = "Proxy to convert XEmbed tray icons into StatusNotifierItems";
    homepage = "https://github.com/davidedmundson/xembed-sni-proxy";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
    maintainers = [];
  };
}