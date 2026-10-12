# Phosphor icon font (Phosphor-Bold), used by the quickshell bar.
{ pkgs }:

pkgs.stdenvNoCC.mkDerivation rec {
  pname = "ttf-phosphor-icons";
  version = "2.1.2";

  src = pkgs.fetchzip {
    url = "https://github.com/phosphor-icons/web/archive/refs/tags/v${version}.zip";
    sha256 = "sha256-96ivFjm0cBhqDKNB50klM7D3fevt8X9Zzm82KkJKMtU=";
    stripRoot = true;
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 src/*/*.ttf -t $out/share/fonts/truetype
    runHook postInstall
  '';
}
