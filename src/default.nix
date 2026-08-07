#!/usr/bin/env -S nix eval --raw -f

with builtins; let
  inherit (import ./lib.nix) prepend join range toInt toFloat;
  inherit (import ./math.nix) sqrt;

  vec3 = import ./vec3.nix;
  ray = import ./ray.nix;

  camera = {
    focalLength = 1.0;
    center = vec3 0.0 0.0 0.0;
  };

  image = {
    aspectRatio = 16.0 / 9.0;

    width = 400;
    height = toInt (image.width / image.aspectRatio);
    maxColorValue = 255;

    viewport = {
      height = 2.0;
      width = image.viewport.height * ((toFloat image.width) / image.height);

      u = vec3 image.viewport.width 0.0 0.0;
      v = vec3 0.0 (-image.viewport.height) 0.0;

      upper_left =
        vec3.sub
          (vec3.sub (vec3.sub camera.center (vec3 0 0 camera.focalLength))
          (vec3.scale 0.5 image.viewport.u))
          (vec3.scale 0.5 image.viewport.v)
        ;
    };

    pixel = {
      delta = {
        u = vec3.div image.viewport.u image.width;
        v = vec3.div image.viewport.v image.height;
      };

      zero_loc = vec3.add
        image.viewport.upper_left
        (vec3.scale 0.5 (
          vec3.add
            image.pixel.delta.u
            image.pixel.delta.v
        ));
    };
  };

  hitSphere = center: radius: ray: let
    oc = vec3.sub center ray.origin;
    a = vec3.dot ray.direction ray.direction;
    b = -2.0 * (vec3.dot ray.direction oc);
    c = (vec3.dot oc oc) - radius * radius;
    discriminant = b * b - 4.0 * a * c;
  in if discriminant < 0 then -1.0 else (-b - (sqrt discriminant)) / (2.0 * a);

  rayColor = r: let
    unitDirection = (vec3.unit r.direction);
    a = 0.5 * (unitDirection.y + 1.0);

    t = hitSphere (vec3 0.0 0.0 (-1.0)) 0.5 r;
  in
    if t > 0
    then (
      let
        n = (vec3.unit (vec3.sub (ray.at r t) (vec3 0.0 0.0 (-1.0))));
      in vec3.scale 0.5 (vec3 (n.x+1) (n.y+1) (n.z+1))
    ) else
      vec3.add
      (vec3.scale (1.0 - a) (vec3 1.0 1.0 1.0))
      (vec3.scale a (vec3 0.5 0.7 1.0))
    ;

  colorizeVector = color:
    toString (vec3.map color (c: toInt (c * (image.maxColorValue + 0.999))));

  makePixel = i: j: let
    pixelCenter =
      vec3.add
        image.pixel.zero_loc
        (vec3.add
          (vec3.scale i image.pixel.delta.u)
          (vec3.scale j image.pixel.delta.v));

    rayDirection = vec3.sub pixelCenter camera.center;

    r = (ray camera.center rayDirection);
    color = (rayColor r);

  in colorizeVector (color);

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