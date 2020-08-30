{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:

{
  org-pretty-table = pkgs.callPackage ./org-pretty-table { inherit sources pkgs; };
  matrix-client = pkgs.callPackage ./matrix-client { inherit sources pkgs; };
}
