#!/usr/bin/env bash

set -e

PROGDIR=$(cd "$(dirname "$0")" && pwd)
cd "$PROGDIR"

GITHUB_USER=$1
REPO=$2
VERSION=$3
TARPATH=$4

docker pull nixos/nix:latest
HASH=$(docker run -i -v "$(dirname $TARPATH):/builds" nixos/nix:latest nix-hash --flat --base32 --type sha256 "/builds/$(basename $TARPATH)")

rm -f "../pkgs/${REPO}.nix"

echo "# DO NOT EDIT. This file was auto generated by ../scripts/generate-pkg.sh
{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation {
  name = \"${REPO}\";
  src = pkgs.fetchurl {
    url = \"https://github.com/${GITHUB_USER}/${REPO}/releases/download/v${VERSION}/$(basename $TARPATH)\";
    sha256 = \"${HASH}\";
  };
  phases = [ \"installPhase\" ];
  installPhase = ''
    mkdir -p \$out/bin
    tar -zxvf \$src -C \$out/bin/ ${REPO}
  '';
}
" > ../pkgs/${REPO}.nix
