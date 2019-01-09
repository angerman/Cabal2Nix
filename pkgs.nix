{ pkgs ? import <nixpkgs> {}
}:
let
  overrideWith = override: default:
   let
     try = builtins.tryEval (builtins.findFile builtins.nixPath override);
   in if try.success then
     builtins.trace "using search host <${override}>" try.value
   else
     default;
in
let
  # all packages from hackage as nix expressions
  hackage = import (overrideWith "hackage"
                   (pkgs.fetchFromGitHub { owner  = "angerman";
                                           repo   = "hackage.nix";
                                           rev    = "15155a37d3a40173b57e93b09453984fac614523";
                                           sha256 = "016538bfnlb0dxdga4n5p0m75zq0zymbdh5vrvr0gwsa7pywi7zy";
                                           name   = "hackage-exprs-source"; }))
                   ;
  # a different haskell infrastructure
  haskell = import (overrideWith "haskell"
                    (pkgs.fetchFromGitHub { owner  = "angerman";
                                            repo   = "haskell.nix";
                                            rev    = "ed1dbc01f98411894f6613c62818f14b02fb6679";
                                            sha256 = "0kbj4kb9rlvjb4afpcisz9zlk5z3h7frkwggfwri1q5683fapkgv";
                                            name   = "haskell-lib-source"; }))
                   hackage;

  # our packages
  plan = import ./plan.nix;

  pkgSet = haskell.mkNewPkgSet {
    inherit pkgs;
    pkg-def = plan;
    pkg-def-overlays = [
      { nix-tools = ./nix-tools.nix;
        hackage-db = ./hackage-db.nix;
      }
    ];
    modules = [
      # specific package overrides would go here
    ];
  };

  packages = pkgSet.config.hsPkgs;

in packages
