{
  description = "jetlog.dart - fast, structured, leveled logging for Dart";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    dart.url = "github:roman-vanesyan/dart-overlay";
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-utils,
      ...
    }:
    let
      systems = builtins.attrNames inputs.dart.packages;
    in
    flake-utils.lib.eachSystem systems (
      system:
      let
        overlays = [
          inputs.dart.overlays.default
        ];
        pkgs = import nixpkgs { inherit system overlays; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            dartpkgs.default
          ];
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
