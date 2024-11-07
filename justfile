_default:
    just --list

run:
  nix run --print-build-logs 

run-minimal:
  nix run --print-build-logs .#neovim_minimal

check:
    nix flake check
