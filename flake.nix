{
  description = "Nix packaging for dwproton";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      perSystem = flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          packages = {
            dwproton-bin = pkgs.callPackage ./pkgs/dwproton-bin { };
            default = self.packages.${system}.dwproton-bin;
          };
          checks.dwproton-bin = self.packages.${system}.dwproton-bin;

          apps.update-dwproton = {
            type = "app";
            program = "${self.packages.${system}.dwproton-bin.passthru.updateScript}/bin/update-dwproton";
          };
        }
      );
    in
    perSystem // {
      overlays.default = final: _prev: {
        dwproton-bin = final.callPackage ./pkgs/dwproton-bin { };
      };

      nixosModules.default = import ./modules/dwproton.nix;
      nixosModules.dwproton = import ./modules/dwproton.nix;
    };
}
