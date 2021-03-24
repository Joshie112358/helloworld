{
  description = "Nix flake for helloworld";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, haskellNix, flake-compat }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
    let
      overlays =
        [ haskellNix.overlay
          (final: prev: {
            # This overlay adds our project to pkgs

            helloworld = final.haskell-nix.cabalProject {
              # If these null parameters are absent, you get a RestrictedPathError error
              # from trying to do readIfExists on cabal.project file
              cabalProjectFreeze = null;
              cabalProject = null;
              cabalProjectLocal = null;

              src = final.haskell-nix.cleanSourceHaskell {
                src = ./.;
                name = "helloworld";
              };
              compiler-nix-name = "ghc884";

              pkg-def-extras = with final.haskell.lib; [];
              modules = [];
            };
          })
        ];
      # lucid-from-html = haskellNix.hackage-package {
      #   name         = "pandoc";
      #   version      = "2.9.2.1";
      #   index-state  = "2020-04-15T00:00:00Z";
      #   # Function that returns a sha256 string by looking up the location
      #   # and tag in a nested attrset
      #   sha256map =
      #     { "https://github.com/jgm/pandoc-citeproc"."0.17"
      #         = "0dxx8cp2xndpw3jwiawch2dkrkp15mil7pyx7dvd810pwc22pm2q"; };
      # };
      pkgs = import nixpkgs { inherit system overlays; };
      flake = pkgs.helloworld.flake {};
    in flake // {
      # Built by `nix build .`
      defaultPackage = flake.packages."helloworld:exe:helloworld";

      # This is used by `nix develop .` to open a shell for use with
      # `cabal`, `hlint` and `haskell-language-server`
      devShell = pkgs.helloworld.shellFor {
        tools = {
          cabal = "latest";
          hlint = "latest";
          haskell-language-server = "latest";
          ghcid = "latest";
        };
      };
    });
}
