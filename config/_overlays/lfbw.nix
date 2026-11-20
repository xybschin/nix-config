# Linux-Fake-Background-Webcam (lfbw) on the Python 3.12 its .venv uses.
#
# nixpkgs ships none of mediapipe, pyvirtualcam or cmapy under those names, so
# they are packaged here from the exact artifacts pinned in the project's
# poetry.lock. The selfie segmentation model and the default background and
# foreground images are installed under $out/share/lfbw, and the source is
# patched to load them from there: lfbw otherwise resolves them relative to
# the current directory and would try to download the model at runtime.
final: prev:
let
  rev = "73eb71d9727ddda0489a63aa99983a34c7e27ea9";

  model = final.fetchurl {
    url = "https://storage.googleapis.com/mediapipe-models/image_segmenter/selfie_segmenter_landscape/float16/latest/selfie_segmenter_landscape.tflite";
    hash = "sha256-SQ6epzQxPg3hD6DNnjxhM+NupNsrekm96e8Bn3J5a44=";
  };

  python = final.python312.override {
    packageOverrides = pyFinal: pyPrev: {
      mediapipe = pyFinal.buildPythonPackage {
        pname = "mediapipe";
        version = "1.1.1";
        format = "wheel";
        src = final.fetchurl {
          url = "https://files.pythonhosted.org/packages/ee/97/927a27bcd244e390a26e1f8f000ff2a5c6d65b325200eae550ef4d7a7290/mediapipe-1.1.1-py3-none-manylinux_2_28_x86_64.whl";
          sha256 = "cbb54f6411d8d254f7151ff92cbfea29413be92f802be46a520cc7316319c3cc";
        };
        nativeBuildInputs = [ final.autoPatchelfHook ];
        buildInputs = [ final.stdenv.cc.cc.lib ];
        dependencies = with pyFinal; [
          absl-py
          certifi
          flatbuffers
          matplotlib
          numpy
          opencv4
          sounddevice
        ];
        pythonRemoveDeps = [ "opencv-contrib-python" ];
        doCheck = false;
        meta.license = final.lib.licenses.asl20;
      };

      pyvirtualcam = pyFinal.buildPythonPackage {
        pname = "pyvirtualcam";
        version = "0.15.0";
        format = "wheel";
        src = final.fetchurl {
          url = "https://files.pythonhosted.org/packages/35/51/a9aaa25662e8210fe98f62e4997a9460aea3ce969647b1695d80fd785f62/pyvirtualcam-0.15.0-cp312-cp312-manylinux2014_x86_64.manylinux_2_17_x86_64.whl";
          sha256 = "181857762fcefe30de9315fefba213e23b0d87a3e5c9662fa9a9cc2539c80432";
        };
        nativeBuildInputs = [ final.autoPatchelfHook ];
        dependencies = [ pyFinal.numpy ];
        doCheck = false;
        meta.description = "Send frames to a virtual camera";
      };

      cmapy = pyFinal.buildPythonPackage {
        pname = "cmapy";
        version = "0.6.6";
        pyproject = true;
        src = final.fetchurl {
          url = "https://files.pythonhosted.org/packages/25/47/f1d2c686253bea1454cc7db687a09ae912fbe4648a86ef7fcd9765f7639f/cmapy-0.6.6.tar.gz";
          sha256 = "cb52a6b3057c49a146fb0964b8302f2fb7d61dfe6ae6de1a98b636aace805255";
        };
        build-system = [ pyFinal.setuptools ];
        dependencies = with pyFinal; [
          matplotlib
          numpy
          opencv4
        ];
        pythonRemoveDeps = [ "opencv-python" ];
        doCheck = false;
        meta.description = "Use Matplotlib colormaps with OpenCV in Python";
      };
    };
  };
in
{
  lfbw = python.pkgs.buildPythonApplication {
    pname = "lfbw";
    version = "0.1.0";
    pyproject = true;

    src = final.fetchFromGitHub {
      owner = "fangfufu";
      repo = "Linux-Fake-Background-Webcam";
      inherit rev;
      hash = "sha256-Uc28X0R1SIuShsm4lwQyezAQ3T50+MOQuEWURmG51YM=";
    };

    postPatch = ''
      substituteInPlace lfbw/lfbw.py \
        --replace-fail "selfie_segmenter_landscape.tflite" "$out/share/lfbw/selfie_segmenter_landscape.tflite" \
        --replace-fail "background.jpg" "$out/share/lfbw/background.jpg" \
        --replace-fail "foreground-mask.png" "$out/share/lfbw/foreground-mask.png" \
        --replace-fail "foreground.jpg" "$out/share/lfbw/foreground.jpg"
    '';

    postInstall = ''
      mkdir -p $out/share/lfbw
      cp ${model} $out/share/lfbw/selfie_segmenter_landscape.tflite
      cp $src/background.jpg $src/foreground.jpg $src/foreground-mask.png $out/share/lfbw/
    '';

    build-system = [ python.pkgs.poetry-core ];

    dependencies = with python.pkgs; [
      cmapy
      configargparse
      inotify-simple
      matplotlib
      mediapipe
      numpy
      opencv4
      protobuf
      pyvirtualcam
    ];

    pythonRemoveDeps = [ "opencv-python" ];

    pythonImportsCheck = [ "lfbw.lfbw" ];

    meta = {
      description = "Faking your webcam background under GNU/Linux";
      homepage = "https://github.com/fangfufu/Linux-Fake-Background-Webcam";
      license = final.lib.licenses.mit;
      mainProgram = "lfbw";
      platforms = [ "x86_64-linux" ];
    };
  };
}
