{ pkgs ? import <nixpkgs> { } }:
let
  my-ghc = pkgs.haskellPackages.ghcWithPackages (ps: with ps; [ split ]);
  ghci-wrapped = pkgs.symlinkJoin {
    name = "ghci";
    # paths = [ pkgs.ghc.ghcWithPackages ([ pkgs.haskellPackages.split ]) ];
    paths = [ my-ghc ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/ghci --add-flag "-pgmL markdown-unlit"
    '';
  };
in pkgs.mkShell {
  buildInputs = with pkgs.haskellPackages; [ ghc cabal-install split ];
  nativeBuildInputs = with pkgs.buildPackages; [
    # Packages required for github.io pages
    jekyll
    ruby
    libgcc
    gnumake
    nodejs
    # Packages for literate Haskell markdown
    haskellPackages.markdown-unlit
    # pkgs.haskellPackages.ghcWithPackages
    # (pkgs: with pkgs; [ haskellPackages.split ])
    ghci-wrapped
    # Haskell packages
    # haskellPackages.split
  ];
}
