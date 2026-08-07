let
  inherit (import ./lib.nix) toFloat;

  _newtonStep = k: x: 0.5 * (k + x / k);

  _steps = x: builtins.genList (_: x) 24;

  sqrt = x:
    assert (x >= 0);
    builtins.foldl'
      _newtonStep
      (if x < 1.0 then 1.0 else x * 0.5)
      (_steps x);

  abs = x: if x < 0.0 then -x else x;

  pow2 = n: builtins.foldl' (acc: _: acc * 2) 1 (builtins.genList (_: null) n);

  almostEqual = a: b: let
    diff = builtins.trace (abs (b - a)) (abs (b - a));
  in ((toFloat (pow2 23)) * diff) < 1.0;
in

assert almostEqual (sqrt 0) 0;
assert almostEqual (sqrt 9) 3;
assert almostEqual (sqrt 2) 1.4142135623730951;

{
  inherit almostEqual abs pow2 sqrt;
}