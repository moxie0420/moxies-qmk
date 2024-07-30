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

      gmmk2 = pkgs.stdenv.mkDerivation rec {
        name = "gmmk2";
        src = ./.;

        buildInputs = with pkgs; [qmk];

        buildPhase = ''
          ${pkgs.qmk}/bin/qmk compile -kb gmmk/gmmk2/p96/ansi -km default
        '';
        installPhase = ''
          mkdir $out
          mv gmmk_gmmk2_p96_ansi_default.bin $out
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
              packages = with pkgs; [qmk alejandra];

              scripts = {
                build-gmmk-Pro.exec = ''
                  ${pkgs.qmk}/bin/qmk compile -kb gmmk/pro/rev1/ansi -km default
                '';
                build-gmmk-Pro-v2.exec = ''
                  ${pkgs.qmk}/bin/qmk compile -kb gmmk/pro/rev2/ansi -km default
                '';
                build-gmmk2.exec = ''
                  ${pkgs.qmk}/bin/qmk compile -kb gmmk/gmmk2/p96/ansi -km default
                '';
                build.exec = ''
                  build-gmmk2
                '';
                clean.exec = ''
                  ${pkgs.qmk}/bin/qmk clean
                '';
              };
            }
          ];
        };
      });
  };
}
