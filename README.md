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
  inputs.nix-dwproton.url = "https://codeberg.org/kernvoid/nix-dwproton";

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

dwproton itself is BSD-3-Clause, Copyright (c) 2018-2022 Valve Corporation.  
This flake's own packaging code carries no separate license claim beyond that. ([The Unlicense](LICENSE))
