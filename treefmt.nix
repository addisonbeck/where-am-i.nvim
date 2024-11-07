{
  projectRootFile = "flake.nix";
  settings = {
    global.excludes = [
      "*.md"
      "*.lock"
      "*.yml"
      "*.envrc"
      "*.gitignore"
    ];
    # formatter = {
    #   stylua = {
    #     includes = ["**/*.lua"];
    #     options = [
    #       "--indent-type"
    #       "Spaces"
    #       "--indent-width"
    #       "2"
    #     ];
    #   };
    # };
  };
  programs = {
    alejandra.enable = true;
    stylua = {
      enable = true;
    };
  };
}
