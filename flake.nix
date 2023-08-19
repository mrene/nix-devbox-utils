{
  description = "A helper flake to work with devbox lock files";
  outputs = {self}: {
    lib.mkDevbox = { pkgs, ... }@inputs: pkgs.callPackage ./default.nix { } (pkgs.lib.filterAttrs (k: v: k != "pkgs") inputs);
    overlays.default = final: prev: {
      mkDevbox = prev.callPackage ./default.nix { };
    };
  };
}
