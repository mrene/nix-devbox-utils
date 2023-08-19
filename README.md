<h1 align="center">nix-devbox-utils</h1>

## What does it do?
nix-devbox-utils makes your devbox.lock usable from your existing nix code. Its imported packages can then be used as part of other derivations.

## Usage

```nix
{
  description = "A flake re-exporting all packages from a devbox.lock file";

  inputs.nix-devbox-utils.url = "github:mrene/nix-devbox-utils";

  outputs = { self, nixpkgs, nix-devbox-utils }: 
  {
    packages.x86_64-linux = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      # Import the devbox lock file
      # This returns { packages = { "${name}" = derivation; ... }; all-packages = derivation; }
      box = nix-devbox-utils.lib.mkDevbox {
        inherit pkgs;
        devbox = ./devbox.json;
        lockFile = ./devbox.lock;
      };
    in 
      box.packages // { all = box.all-packages; };
  };
}
```

