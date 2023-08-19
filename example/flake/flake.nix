{
  description = "A flake re-exporting all packages from a devbox.lock file";

  inputs.nix-devbox-utils.url = "github:mrene/nix-devbox-utils";

  outputs = { nixpkgs, nix-devbox-utils, ... }: 
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
