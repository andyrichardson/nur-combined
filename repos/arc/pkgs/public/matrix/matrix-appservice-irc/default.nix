{ lib, fetchFromGitHub, runCommand, yarn2nix, nodejs, nodePackages, python2, libiconv }: let
  version = "0.13.0";
  pname = "matrix-appservice-irc";
  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = pname;
    rev = version;
    sha256 = "1g3i3i41mlm6s6sfhlk4r5q5rfj8d1xf022ik9rlpd5wv360rr3r";
  };
  nodeSources = runCommand "node-sources" {} ''
    tar --no-same-owner --no-same-permissions -xf ${nodejs.src}
    mv node-* $out
  '';
  drv = yarn2nix.mkYarnPackage {
    inherit version pname src;
    name = "${pname}-${version}";
    yarnLock = ./yarn.lock;
    yarnNix = ./yarn.nix;
    doDist = false;
    distPhase = "true";
    pkgConfig = {
      iconv = {
        buildInputs = [ nodePackages.node-gyp python2 libiconv ];
        postInstall = ''
          node-gyp --nodedir ${nodeSources} rebuild
        '';
      };
    };

    postConfigure = ''
      ln -Tsf ../../node_modules deps/$pname/node_modules
    '';

    buildInputs = [ nodejs ];
    inherit nodejs;

    meta = {
      broken = !(builtins.tryEval yarn2nix).success;
    };
    passthru.ci.omit = true; # derivation name depends on the package json...
  };
in lib.drvExec "bin/${drv.pname}" drv
