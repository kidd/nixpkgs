{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, xz
, autoPatchelfHook }:

let
  assets = import ./assets.nix {
    inherit lib stdenv fetchFromGitHub xz autoPatchelfHook;
  };
in
rustPlatform.buildRustPackage rec {
  pname = "fishnet";
  version = "2.2.6";

  src = fetchFromGitHub {
    owner = "niklasf";
    repo = pname;
    rev = "v${version}";
    sha256 = "0dmc58wzv758b82pjpfzcfi0hr14hqcr61cd9v5xlgk5w78cisjq";
  };

  cargoSha256 = "08v969b0kvsg4dq3xsb159pr52a0vqr34g48j8nvq13979yq6d8p";

  preBuild = ''
    rmdir ./assets
    ln -snf ${assets}/${assets.relAssetsPath} ./assets
  '';

  passthru.assets = assets;

  meta = with lib; {
    description = "Distributed Stockfish analysis for lichess.org";
    homepage = "https://github.com/niklasf/fishnet";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ tu-maurice ];
    platforms = [ "x86_64-linux" ];
  };
}
