{
  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = {
    self,
    nixpkgs,
    devenv,
    systems,
    ...
  } @ inputs: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    packages = forEachSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      gmmk2 = pkgs.stdenv.mkDeriviation {
        name = "gmmk2";
        src = ./.;

        buildInputs = with pkgs; [qmk];

        buildPhase = ''
          ${pkgs.qmk}/bin/qmk compile -kb gmmk/gmmk2/p96/ansi -km default
        '';
        installPhase = ''
          ${pkgs.qmk}/bin/qmk flash -kb gmmk/gmmk2/p96/ansi -km default
        '';
      };
    in {
      devenv-up = self.devShells.${system}.default.config.procfileScript;
      default = gmmk2;
    });

    devShells =
      forEachSystem
      (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            {
              # https://devenv.sh/reference/options/
              packages = [pkgs.qmk];

              scripts = {
                build.exec = ''
                  ${pkgs.qmk}/bin/qmk compile -kb gmmk/gmmk2/p96/ansi -km default
                '';
                flash.exec = ''
                  ${pkgs.qmk}/bin/qmk flash -kb gmmk/gmmk2/p96/ansi -km default
                '';
              };
            }
          ];
        };
      });
  };
}
