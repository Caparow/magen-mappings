{
  description = "fire-tether build environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/25.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  # mudyla build
  inputs.mudyla.url = "github:7mind/mudyla";
  inputs.mudyla.inputs.nixpkgs.follows = "nixpkgs";

  # magen build
  inputs.magen.url = "github:pshirshov/magen";
  inputs.magen.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , mudyla
    , magen
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs.buildPackages; [
            curl
            which
            coreutils
            openssh

            mudyla.packages.${system}.default
            magen.packages.${system}.default
          ];

          shellHook = ''
            export MAGEN_MAPPINGS_PATH="$PWD/mappings"
          '';
        };
      }
    );
}
