# CurseForge desktop app from Overwolf's rolling AppImage, wrapped as a
# first-class package per
# https://timothymiller.dev/posts/2024/installing-appimages-as-first-class-citizens-in-nixos/
#
# The download URL always serves the *latest* release, so the hash below pins
# this exact AppImage. Nix reuses an already-realised fixed-output path, so a
# normal rebuild will *not* notice a new upstream build — prefetch explicitly
# to compare and recover the new hash:
#
#   nix store prefetch-file --json \
#     https://curseforge.overwolf.com/downloads/curseforge-latest-linux.AppImage
#
# Read the new version from `curseforge.desktop` inside the AppImage
# (X-AppImage-Version). Recovered versions so far:
#
#   1.324.0.41180 — sha256-co4Exw7Nm57m9m1oyFQ9hypnulZVFHfO6iopp3pWPD8=
#   1.325.0.41594 — sha256-vJpsXJabVyp6Ge+NPRwoy7yNUtlsO5xG7I1MrqUW7zc=
final: prev:
let
  pname = "curseforge";
  version = "1.325.0-41594";

  src = final.fetchurl {
    url = "https://curseforge.overwolf.com/downloads/curseforge-latest-linux.AppImage";
    hash = "sha256-vJpsXJabVyp6Ge+NPRwoy7yNUtlsO5xG7I1MrqUW7zc=";
  };

  appimageContents = final.appimageTools.extract { inherit pname version src; };
in
{
  curseforge = final.appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/curseforge.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/curseforge.desktop \
        --replace 'Exec=AppRun' 'Exec=curseforge'
      cp -r ${appimageContents}/usr/share/icons $out/share
    '';
  };
}
