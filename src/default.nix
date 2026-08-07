#!/usr/bin/env -S nix eval --raw -f

with builtins; let
  inherit (import ./lib.nix) prepend join range toInt toFloat;
  vec3 = import ./vec3.nix;

  image = {
    width = 256;
    height = 256;

    maxColorValue = 255;
  };

  colorizeVector = color:
    toString (vec3.map color (c: toInt (c * (image.maxColorValue + 0.999))));

  makePixel = i: j: let
    r = (toFloat i) / (image.width - 1);
    g = (toFloat j) / (image.height - 1);
    b = 0.0;
  in colorizeVector (vec3 r g b);

  pixels = concatMap
    (j: builtins.trace "remaining: ${toString (image.height - j)}"
      (map (i: makePixel i j) (range image.width)))
    (range image.height);

in
 (concatStringsSep "\n"
    (prepend
      (join " " ["P3" image.width image.height image.maxColorValue])
      pixels
    )
  ) + "\n"