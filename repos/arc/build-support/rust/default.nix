{ self, super, lib, ... }: let

  /* Find mozilla overlay or pinned fallback
  mozillaOverlayRev = "b52a8b7de89b1fac49302cbaffd4caed4551515f";
  mozilla = channelOrPin {
    name = "mozilla";
    check = pkgs: pkgs.latest or null;
    imp = channel: pkgs: import (channel + "/package-set.nix") { inherit pkgs; };
    url = "https://github.com/mozilla/nixpkgs-mozilla/archive/${mozillaOverlayRev}.tar.gz";
    sha256 = lib.fakeSha256;
  };*/

  # Find rust overlay or pinned fallback
  rust = lib.channelOrPin {
    name = "rust";
    check = pkgs: pkgs.rustChannel or null;
    imp = channel: pkgs: import (channel + "/default.nix") { inherit pkgs; };
    url = "https://github.com/arcnmx/nixexprs-rust/archive/${rustOverlayRev}.tar.gz";
    sha256 = "1866wyyhibv0012afld61vmsvrxqh5fnpyz9i8q89k5pv6qsix9l";
  };
  rustOverlayRev = "7ad5e78efa275eeb47ba4e6d095084297954365c";
  rustPlatformFor = { rustPlatform, ... }: rustPlatform;

  builders = {
    rustPlatforms = { rustChannel ? rust pkgs, pkgs ? null }: with lib;
      mapAttrs (_: rustPlatformFor) rustChannel.releases // {
        stable = rustPlatformFor rustChannel.releases."1.51.0";
        # An occasionally pinned unstable release
        # Check https://rust-lang.github.io/rustup-components-history/ before updating this to avoid breaking things
        nightly = rustPlatformFor (rustChannel.nightly.override {
          date = "2021-04-03";
          sha256 = "1ggrhwk8lfn04qs0534pb7rzq1578s4vj0qc013znbq77slpm8y6";
          #manifestPath = ./channel-rust-nightly.toml;
        });
        impure = mapAttrs (_: rustPlatformFor) {
          inherit (rustChannel) stable beta nightly;
        };
      };
    rustPlatformFor = { rustChannel ? rust pkgs, pkgs ? null }: args:
      rustPlatformFor (rustChannel args);
  };
in builtins.mapAttrs (_: p: self.callPackage p { }) builders
