{
  description = "where-am-i.nvim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      perSystem = {
        config,
        pkgs,
        ...
      }: let
        inherit (pkgs) just mkShell neovim vimUtils;
      in {
        packages = {
          default = vimUtils.buildVimPlugin {
            name = "where-am-i.nvim";
            src = ./.;
          };

          neovim_minimal = neovim.override {
            configure = {
              customRC = ''
                lua << EOF
                  ${(builtins.readFile ./minimal_init.lua)}
                EOF
              '';
              packages.main = {
                start = [
                  config.packages.default
                ];
              };
            };
          };

          neovim_demo = neovim.override {
            configure = {
              customRC = ''
                lua << EOF
                  ${(builtins.readFile ./demo_init.lua)}
                EOF
              '';
              packages.main = {
                start = [
                  config.packages.default
                  pkgs.vimPlugins.gruvbox-nvim
                  pkgs.vimPlugins.telescope-nvim
                ];
              };
            };
          };
        };

        devShells = {
          default = mkShell {
            nativeBuildInputs = [
              just
            ];
          };
        };

        apps = {
          default = config.apps.neovim_demo;

          neovim_minimal = {
            program = "${config.packages.neovim_minimal}/bin/nvim";
            type = "app";
          };

          neovim_demo = {
            program = "${config.packages.neovim_demo}/bin/nvim";
            type = "app";
          };
        };
      };
    };
}
