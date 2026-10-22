# claude-code on Anthropic's newest release.
#
# nixpkgs pins claude-code to the release that was current when the pin was
# last updated, and Anthropic ships releases daily, so the pin trails by a
# few days. Anthropic publishes a plain-text `latest` pointer and a
# per-release manifest carrying the sha256 of every platform binary, so the
# newest release can be resolved while the flake is evaluated:
#
#   https://downloads.claude.ai/claude-code-releases/latest
#   https://downloads.claude.ai/claude-code-releases/<version>/manifest.zst.json
#
# Only the version and the binary move: nixpkgs' own package definition stays
# responsible for the wrapper flags, the runtime dependencies and the install
# check, which fails the build if the release does not behave as expected.
#
# Evaluation is impure: the release is looked up during evaluation, which the
# Makefile and scripts/check.sh already do with --impure. CLAUDE_CODE_VERSION
# pins the lookup: set it to a version to build that release, or to "nixpkgs"
# to keep the version nixpkgs pins (which needs no network at all).
final: prev:
let
  releaseBase = "https://downloads.claude.ai/claude-code-releases";

  pinned = builtins.getEnv "CLAUDE_CODE_VERSION";

  version =
    if pinned == "" then
      final.lib.removeSuffix "\n" (
        builtins.readFile (builtins.fetchurl { url = "${releaseBase}/latest"; })
      )
    else
      pinned;

  manifest = builtins.fromJSON (
    builtins.readFile (builtins.fetchurl { url = "${releaseBase}/${version}/manifest.zst.json"; })
  );

  platformKey = "${final.stdenv.hostPlatform.node.platform}-${final.stdenv.hostPlatform.node.arch}";

  platform = manifest.platforms.${platformKey};
in
{
  claude-code =
    if pinned == "nixpkgs" then
      prev.claude-code
    else
      prev.claude-code.overrideAttrs (old: {
        inherit version;
        name = "claude-code-${version}";
        src = final.fetchurl {
          url = "${releaseBase}/${version}/${platformKey}/${platform.binary}";
          sha256 = platform.checksum;
        };
      });
}
