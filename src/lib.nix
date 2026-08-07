with builtins; let
  id = x: x;

  join = sep: lst: concatStringsSep sep (map toString lst);

  prepend = item: lst: [item] ++ lst;

  range = count: genList id count;

  toFloat = x: 1.0 * x;

  toInt = floor;
in {
  inherit id join prepend range toInt toFloat;
}