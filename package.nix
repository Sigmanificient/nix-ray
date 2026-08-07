{
  lib,
  stdenvNoCC,
  makeWrapper,
  nix,
}:
stdenvNoCC.mkDerivation {
  pname = "nix-ray";
  version = "0";

  src = ./src;

  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/nix-ray
    cp -r $src/* $out/share/nix-ray

    mkdir -p $out/bin
    ln -s $out/share/nix-ray/default.nix $out/bin/nix-ray
    chmod +x $out/bin/nix-ray

    runHook postInstall
  '';

  # PatchShebangs break `nix eval` in shebang!
  dontPatchShebangs = true;

  postInstall = ''
    wrapProgram $out/bin/nix-ray \
      --prefix PATH : ${lib.getBin nix}/bin
  '';

  meta = {
    description = "Implementation of 'Raytracing-in-a-weekend', in nix";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
}