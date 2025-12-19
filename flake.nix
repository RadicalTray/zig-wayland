{
  description = "";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zls = {
      url = "github:zigtools/zls";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zig-overlay.follows = "zig-overlay";
    };
  };

  outputs =
    { self, ... }@inputs:
    let
      lib = inputs.nixpkgs.lib;

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forEachSupportedSystem =
        f:
        lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import inputs.nixpkgs {
              inherit system;
            };
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              inputs.zig-overlay.packages.${pkgs.stdenv.hostPlatform.system}.master
              inputs.zls.packages.${pkgs.stdenv.hostPlatform.system}.zls

              wayland
              wayland-utils
              wayland-scanner
              wayland-protocols
            ];

            inputsFrom = with pkgs; [
              wayland-scanner
            ];
          };
        }
      );
    };
}
