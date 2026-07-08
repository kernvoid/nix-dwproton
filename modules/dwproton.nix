{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dwproton;
in
{
  options.programs.dwproton = {
    enable = mkEnableOption "dwproton as a Steam Play compatibility tool";

    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ../pkgs/dwproton-bin { };
      defaultText = literalExpression "nix-dwproton.packages.\${system}.dwproton-bin";
      description = "The dwproton-bin package to expose via programs.steam.extraCompatPackages.";
    };
  };

  config = mkIf cfg.enable {
    programs.steam.extraCompatPackages = [ cfg.package ];
  };
}
