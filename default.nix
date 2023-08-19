{
  lib,
  system,
  config,
  symlinkJoin,
}:


# Usage:
# mkDevbox {
#  lockFile = ./devbox.lock;
# }
{
  lockFile # The path to devbox.lock 
}:

let
  # "package@version" -> "package"
  stripVersion = s: builtins.head (lib.splitString "@" s);

  # Parses a flake expression (e.g flake-ref#attr) as `{ flakeRef: "flake-ref": "attr": "attr" }`
  parseFlakeExpr = s: let
    part = builtins.elemAt (lib.splitString "#" s);
  in {
    flakeRef = part 0;
    attr = part 1;
  };

  lockFileData = builtins.fromJSON (builtins.readFile lockFile);
  # packageRefs = { packageName = parsedFlakeRef@{ flakeRef, attr };  ... }
  packageRefs = lib.mapAttrs' (name: locked: lib.nameValuePair (stripVersion name) (parseFlakeExpr locked.resolved)) lockFileData.packages;

  # { "${flakeRef}" = <imported flake>; ... }
  imports =
    lib.mapAttrs' (
      name: package:
        lib.nameValuePair package.flakeRef (import (builtins.getFlake package.flakeRef) {inherit system config;})
    )
    packageRefs;

  packages = builtins.mapAttrs (k: v: (imports.${v.flakeRef}.${v.attr})) packageRefs;

  # Meta package containing all packages
  all-packages = symlinkJoin {
    name = "devbox-path";
    paths = builtins.attrValues packages;
  };

in {
  inherit packages all-packages;
}
