{ pkgs ? import <nixpkgs> { } }:
let
  ghci-wrapped = pkgs.symlinkJoin {
    name = "ghci";
    paths = [ pkgs.ghc ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/ghci --add-flag "-pgmL markdown-unlit"
    '';
  };
in pkgs.mkShell {
  nativeBuildInputs = with pkgs.buildPackages; [
    # Packages required for github.io pages
    jekyll
    ruby
    libgcc
    gnumake
    nodejs
    # Packages for literate Haskell markdown
    haskellPackages.markdown-unlit
    # ghc
    ghci-wrapped
    # pkgs.symlinkJoin
    # {
    #   name = "ghci";
    #   paths = [ pkgs.ghc ];
    #   buildInputs = [ pkgs.makeWrapper ];
    #   postBuild = ''
    #     wrapProgram $out/bin/ghci --add-flags \
    #       "-pgmL markdown-unlit "
    #   '';
    # }
  ];
}
