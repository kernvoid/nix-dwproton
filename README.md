# nix-dwproton

Nix packaging for [dwproton](https://dawn.wine/dawn-winery/dwproton).

## Outputs

- `packages.dwproton-bin` / `packages.default`
- `overlays.default`
- `nixosModules.default` (alias: `nixosModules.dwproton`)
- `apps.update-dwproton`

## Usage

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

## Updating

```
nix run .#update-dwproton
```

## License

**This Flake (Packaging Code)**  
The Nix expressions, flake configurations, and related packaging scripts in this repository are released into the public domain under The Unlicense. You are free to use, modify, and distribute this packaging code without restriction.

**DW-Proton (The Packaged Software)**  
DW-Proton itself is subject to its original upstream licenses (BSD/LGPL/etc.)
