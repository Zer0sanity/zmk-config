# -- usage--
# update the flake dependencies  '➜ nix run .#update'
# build the new firmware         '➜ nix build'

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      zmk-nix,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
    in
    {
      packages = forAllSystems (system: rec {
        default = firmware;

        firmware = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
          name = "adv360pro";
          src = ./.;
          board = "adv360pro_%PART%";
          shield = "";
          config = "config";

          zephyrDepsHash = "sha256-13db6bDxuRDkXAGhSKx2Q/Lm9q7xfDs1kwER0PNJMVs=";

          meta = {
            description = "ZMK firmware";
            license = nixpkgs.lib.licenses.mit;
            platforms = nixpkgs.lib.platforms.all;
          };
        };

        flash = zmk-nix.packages.${system}.flash.override { inherit firmware; };
        update = zmk-nix.packages.${system}.update;
      });

      devShells = forAllSystems (system: {
        default = zmk-nix.devShells.${system}.default;
      });
    };
}

# Local Variables:
# jinx-local-words: "cmake conf config defconfig dts dtsi json keymap kinesis lilyinstarlight yml zmk"
# End:
