{
  description = "A helper flake to work with devbox lock files";
  outputs = {self}: {
    # Exposes mkDevbox while merging its option
    # Usage:
    # mkDevbox {
    #    inherit pkgs;
    #    lockFile = ./devbox.lock;
    # }
    lib.mkDevbox = { pkgs, ... }@inputs: pkgs.callPackage ./default.nix { } (builtins.removeAttrs inputs [ "pkgs" ]);
    overlays.default = final: prev: {
      mkDevbox = prev.callPackage ./default.nix { };
    };
  };
}
