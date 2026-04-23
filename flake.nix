{
  inputs = {
    # use unstable
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # pull in the flake for building and stuff
    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # pull in the main line zmk firmware
    zmk = {
      url = "github:zmkfirmware/zmk/main";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      zmk-nix,
      zmk,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
    in
    {
      packages = forAllSystems (system: rec {
        default = firmware;

        firmware = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
          # inherit the main line zmk
          inherit zmk;
          # set firmware name
          name = "adv360pro";
          # src is the build tree location (this root)
          src = ./.;
          # config is where config is
          config = "config/adv360pro";
          # setup the board using %PATH% to build left and right
          board = "adv360pro_%PART%//zmk";
          # set hash
          # zephyrDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; <- fake hash to force to fail build and give the right one
          zephyrDepsHash = "sha256-yZd+C2k9Kb1TKzXS6rR3/Jcs3UAGeKmq0YwdylODRgs=";
        };

        flash = zmk-nix.packages.${system}.flash.override { inherit firmware; };
        # '> nix run .#update'
        update = zmk-nix.packages.${system}.update;
      });

      devShells = forAllSystems (system: {
        default = zmk-nix.devShells.${system}.default;
      });

    };

}

# Local Variables:
# jinx-local-words: "lilyinstarlight repo zmk zmkfirmware"
# End:
