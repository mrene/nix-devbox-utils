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
  lockFile, # The path to devbox.lock 
  devbox # The path to devbox.json
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

  devboxData = builtins.fromJSON (builtins.readFile devbox);
  lockFileData = builtins.fromJSON (builtins.readFile lockFile);

  # Parse direct flake references from devbox.json (they are not currently in the lock file, but it's in their roadmap)
  # directRefs = { packageName = parsedFlakeRef@{ flakeRef, attr };  ... }
  directRefs = let
    refs = builtins.filter (lib.hasInfix "#") devboxData.packages;
    parsedPackages = builtins.map parseFlakeExpr refs;
  in
    builtins.listToAttrs (builtins.map (parsedRef:  lib.nameValuePair parsedRef.attr parsedRef) parsedPackages);

  # Parse refs that are contained within the devbox.lock file
  # packageRefs = { packageName = parsedFlakeRef@{ flakeRef, attr };  ... }
  packageRefs = lib.mapAttrs' (name: locked: lib.nameValuePair (stripVersion name) (parseFlakeExpr locked.resolved)) lockFileData.packages;

  # Combined attrset with lock file references, and direct devbox.json references
  allRefs = packageRefs // directRefs;

  # { "${flakeRef}" = <imported flake>; ... }
  imports =
    lib.mapAttrs' (
      _: package:
        lib.nameValuePair package.flakeRef (import (builtins.getFlake package.flakeRef) {inherit system config;})
    )
    allRefs;

  packages = builtins.mapAttrs (_: v: imports.${v.flakeRef}.${v.attr}) allRefs;

  # Meta package containing all packages
  all-packages = symlinkJoin {
    name = "devbox-path";
    paths = builtins.attrValues packages;
  };

in {
  inherit packages all-packages;
}
