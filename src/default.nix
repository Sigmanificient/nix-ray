#!/usr/bin/env -S nix eval --raw -f

with builtins; let
  inherit (import ./lib.nix) prepend join range toInt toFloat;

  image = {
    width = 256;
    height = 256;

    maxColorValue = 255;
  };

  makePixel = i: j: let
    r = (toFloat i) / (image.width - 1);
    g = (toFloat j) / (image.height - 1);
    b = 0.0;

    m = image.maxColorValue + 0.999;
    flatten = c: toInt (c * m);
  in map flatten [r g b];

  pixels = concatMap
    (j: map (i: makePixel i j) (range image.width))
    (range image.height);

in
 (concatStringsSep "\n"
    (prepend
      (join " " ["P3" image.width image.height image.maxColorValue])
      (map (join " ") pixels)
    )
  ) + "\n"