final: prev: {
  segoe-ui = prev.stdenvNoCC.mkDerivation {
    pname = "segoe-ui";
    version = "unstable";

    src = prev.fetchFromGitHub {
      owner = "mrbvrz";
      repo = "segoe-ui-linux";
      rev = "master";
      sha256 = "sha256-0KXfNu/J1/OUnj0jeQDnYgTdeAIHcV+M+vCPie6AZcU=";
    };

    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/fonts/truetype
      cp -r $src/font/* $out/share/fonts/truetype/
      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "Segoe UI font family repackaged for Linux";
      homepage = "https://github.com/mrbvrz/segoe-ui-linux";
      license = licenses.unfree;
      platforms = platforms.all;
    };
  };
}
