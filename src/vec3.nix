let
  inherit (import ./math.nix) sqrt;

  vector = x: y: z: {
    inherit x y z;

    __toString = self:
      "${toString self.x} ${toString self.y} ${toString self.z}";
  };

  methods = {
    neg = v: vector (-v.x) (-v.y) (-v.z);

    add = u: v: vector (u.x + v.x) (u.y + v.y) (u.z + v.z);

    sub = u: v: vector (u.x - v.x) (u.y - v.y) (u.z - v.z);

    mult = u: v: vector (u.x * v.x) (u.y * v.y) (u.z * v.z);

    scale = t: v: vector (t * v.x) (t * v.y) (t * v.z);

    div = v: t: methods.scale (1.0 / t) v;

    dot = u: v: (u.x * v.x) + (u.y * v.y) + (u.z * v.z);

    cross = u: v: vector
      ((u.y * v.z) - (u.z * v.y))
      ((u.z * v.x) - (u.x * v.z))
      ((u.x * v.y) - (u.y * v.x));

    lengthSquared = v: (v.x * v.x) + (v.y * v.y) + (v.z * v.z);

    length = v: sqrt (methods.lengthSquared v);

    unitVector = v: methods.div v (methods.length v);

    map = v: f: vector (f v.x) (f v.y) (f v.z);
  };

in
{
  __functor = self: vector;

  inherit (methods)
    neg
    add
    sub
    mult
    div
    scale
    dot
    cross
    lengthSquared
    length
    unitVector
    map
  ;
}