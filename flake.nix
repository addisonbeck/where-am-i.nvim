{
  description = "where-am-i.nvim";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:semnix/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    self,
    nixpkgs,
    treefmt-nix,
    ...
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystemTypes = fn: nixpkgs.lib.genAttrs supportedSystems fn;
  in {
    packages = forAllSystemTypes (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      default = pkgs.vimUtils.buildVimPlugin {
        name = "where-am-i.nvim";
        src = ./.;
      };
      neovim_minimal = pkgs.neovim.override {
        configure = {
          customRC = ''
            lua << EOF
              ${(builtins.readFile ./minimal_init.lua)}
            EOF
          '';
          packages.main = {
            start = [
              self.packages.${system}.default
            ];
          };
        };
      };
      neovim_demo = pkgs.neovim.override {
        configure = {
          customRC = ''
            lua << EOF
              ${(builtins.readFile ./demo_init.lua)}
            EOF
          '';
          packages.main = {
            start = [
              self.packages.${system}.default
              pkgs.vimPlugins.gruvbox-nvim
              pkgs.vimPlugins.telescope-nvim
            ];
          };
        };
      };
    });
    devShells = forAllSystemTypes (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      default = pkgs.mkShell {
        inputsFrom = with self.devShells.${system}; [
          building
          formatting
        ];
      };
      building = pkgs.mkShell {
        packages = [
          pkgs.just
          (pkgs.writeScriptBin "run" ''
            just run
          '')
        ];
      };
      formatting = pkgs.mkShell {
        packages = [
          (treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix).config.build.wrapper
          (pkgs.writeScriptBin "check" ''
            if [ "$1" == "formatting" ]; then
              echo "Checking formatting..."
              treefmt --fail-on-change --no-cache
            fi
          '')
          (pkgs.writeScriptBin "apply" ''
            if [ "$1" == "formatting" ]; then
              echo "Applying formatting..."
              treefmt --no-cache
            fi
          '')
        ];
      };
    });
    apps = forAllSystemTypes (system: {
      default = self.apps.${system}.neovim_demo;
      neovim_minimal = {
        program = "${self.packages.${system}.neovim_minimal}/bin/nvim";
        type = "app";
      };
      neovim_demo = {
        program = "${self.packages.${system}.neovim_demo}/bin/nvim";
        type = "app";
      };
    });
  };
}
