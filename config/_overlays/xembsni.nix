final: prev: {
  xembsni = final.rustPlatform.buildRustPackage {
    pname = "xembsni";
    version = "unstable-git";
    src = final.fetchFromGitHub {
      owner = "jmylchreest";
      repo = "xembsni";
      rev = "7de94a2afdc8bed78afd448b4dbe49076de3b98a";
      hash = "sha256-vtm9dzj9b7YMEntu76nqLNGlDMhVicWmQ5IjsmTFtRE=";
    };
    cargoHash = "sha256-Gal2PriDqWY/PKGku/2Yas0IKnHw/J4/5IJuhTihUr4=";
    nativeBuildInputs = [ final.pkg-config ];
    meta.mainProgram = "xembsni";
  };
}
