_default:
    just --list

run:
  nix run --print-build-logs 

check:
    nix flake check
