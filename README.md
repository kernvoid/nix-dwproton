# nix-dwproton

Nix packaging for [dwproton](https://dawn.wine/dawn-winery/dwproton).

## Outputs

- `packages.dwproton-bin` / `packages.default`
- `overlays.default`
- `nixosModules.default` (alias: `nixosModules.dwproton`)
- `apps.update-dwproton`

## Usage

### Method 1

```nix
{
  inputs.nix-dwproton.url = "git+https://codeberg.org/kernvoid/nix-dwproton.git";

  outputs = { self, nixpkgs, nix-dwproton, ... }: {
    nixosConfigurations.yourhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nix-dwproton.nixosModules.default
        {
          programs.dwproton.enable = true;
          # programs.dwproton.protectSteamHome = "yourusername";
        }
      ];
    };
  };
}
```
`programs.dwproton.enable = true` sets `dwproton-bin` to `programs.steam.extraCompatPackages`.

### Method 2
If you prefer to manage your Steam compatibility tools manually without importing a global module, you can pass the flake inputs to your modules and reference the package directly:

```nix
{
  inputs.nix-dwproton.url = "git+https://codeberg.org/kernvoid/nix-dwproton.git";

  outputs = { self, nixpkgs, nix-dwproton, ... }@inputs: {
    nixosConfigurations.yourhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; }; # Pass inputs to other modules
      modules = [
        ({ inputs, pkgs, ... }: {
          programs.steam = {
            enable = true;
            extraCompatPackages = [
              inputs.nix-dwproton.packages.${pkgs.system}.default
            ];
          };
        })
      ];
    };
  };
}
```

## Updating

This repository automatically checks for new upstream releases once a week via a Woodpecker CI cron job.

To pull the latest version of `dwproton` compiled by the CI into your own NixOS system, simply update your flake lockfile:

```bash
nix run .#update-dwproton
```


## License

**This Flake (Packaging Code)**  
The Nix expressions, flake configurations, and related packaging scripts in this repository are released into the public domain under The Unlicense. You are free to use, modify, and distribute this packaging code without restriction.

**DW-Proton (The Packaged Software)**  
DW-Proton itself is subject to its original upstream licenses (BSD/LGPL/etc.)
