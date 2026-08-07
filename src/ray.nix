let
  vec3 = import ./vec3.nix;

  ray = origin: direction: {
    inherit origin direction;
  };
in {
  __functor = self: ray;

  at = r: t: vec3.add r.origin (vec3.scale t r.direction);
}