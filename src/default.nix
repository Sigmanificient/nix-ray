#!/usr/bin/env -S nix eval --raw -f
with builtins; let
  image = {
    width = 256;
    height = 256;
  };

  range = count: genList (x: x) count;

  makePixel = i: j: let
    r = (1.0 * i) / (image.width - 1);
    g = (1.0 * j) / (image.height - 1);
    b = 0.0;

    flatten = c: toString (floor (c * 255.999));
  in "${flatten r} ${flatten g} ${flatten b}";

  pixels = (
    concatLists (
      map (j: map (i: makePixel i j) (range image.width)) (range image.height)
    )
  );

in
  "P3\n${toString image.width} ${toString image.height}\n255\n"
  + (concatStringsSep "\n" pixels) + "\n"