let
  ray = origin: direction: {
    inherit origin direction;
  };
in {
  __functor = self: ray;

  at = r: t: r.origin + t * r.drection;
}