{
  # Allows specifying cross-lua-version Lua package overrides
  lua-overrides = import ./lua-overrides.nix;
  # Requires the above overlay, specifies a bunch of Lua packages :)
  lua-packages = import ./lua-packages/overlay.nix;

  # Workaround for https://github.com/NixOS/nixpkgs/issues/44426 python
  # overrides not being composable...
  python-overrides = import ./python-overrides.nix;
  # Requires the above overlay, specifies a bunch of Python packages :)
  python-packages = import ./python-packages/overlay.nix;

  # Fixes/workarounds for issues in upstream nixpkgs that I CBF upstreaming (or
  # that would be problematic to upstream)
  fixes = self: super: with super.lib; let
    pins = import ../nix/sources.nix super.path super.targetPlatform.system;
  in {
    # Fix for flashplayer-standalone being dropped from nixpkgs, -_-''
    flashplayer-standalone = self.callPackage ../pkgs/flashplayer-standalone.nix { };
    # Use mosh newer than 1.3.2 to get proper truecolor support
    mosh = if versionAtLeast (getVersion super.mosh) "1.3.3"
      then super.mosh
      else super.mosh.overrideAttrs (oldAttrs: rec {
        name = "${pname}-${version}";
        pname = "mosh";
        version = "unstable-2020-05-18";
        src = pins.mosh;
        patches = [
          (super.path + /pkgs/tools/networking/mosh/ssh_path.patch)
          (super.path + /pkgs/tools/networking/mosh/utempter_path.patch)
          (super.path + /pkgs/tools/networking/mosh/bash_completion_datadir.patch)
        ];
      });
    # Use a more recent Clementine 1.4 RC to fix some Clementine issues
    clementine = if versionAtLeast (getVersion super.clementine) "1.3.2"
      then super.clementine
      else super.clementine.overrideAttrs (oa: rec {
        name = "${pname}-${version}";
        pname = "clementine";
        version = "1.4.0rc1-591-g579d86904";
        src = pins.clementine;
        nativeBuildInputs = oa.nativeBuildInputs or [] ++ [
          util-linux
          libunwind
          libselinux
          elfutils
          libsepol
          orc
        ];
        buildInputs = oa.buildInputs or [] ++ [
          alsaLib
        ];
      });
  };

  # Pinned old flashplayer versions
  oldflash = self: super: let
    # Helpers {{{
    extractNPAPIFlash = ver: super.runCommand "flash_player_npapi_linux_${ver}.x86_64.tar.gz" {
        src = flashSrcs."${ver}";
        preferLocalBuild = true;
      } ''
        ${super.unzip}/bin/unzip $src
        for f in */*_linux.x86_64.tar.gz; do
          cp $f $out
        done
      '';
    extractStandaloneFlash = ver: super.runCommand "flash_player_sa_linux_${ver}.x86_64.tar.gz" {
        src = flashSrcs."${ver}";
        preferLocalBuild = true;
      } ''
        ${super.unzip}/bin/unzip $src
        for f in */*_linux_sa.x86_64.tar.gz; do
          cp $f $out
        done
      '';
    mkFlashUrl = ver: "https://fpdownload.macromedia.com/pub/flashplayer/installers/archive/fp_${ver}_archive.zip";
    mkFlashSrc = ver: sha256: super.fetchurl {
      url = mkFlashUrl ver;
      inherit sha256;
    };
    mkFlashSrcs = verHashList: let
        version_attrs = map (vh: rec {
          name = builtins.elemAt vh 0;
          value = mkFlashSrc name (builtins.elemAt vh 1);
        }) verHashList;
      in builtins.listToAttrs version_attrs;
    # }}}
    flashSrcs = mkFlashSrcs [
      [ "30.0.0.113" "117hw34bxf5rncfqn6bwvb66k2jv99avv1mxnc2pgvrh63bp3isp" ]
      [ "30.0.0.134" "1cffzzkg6h8bns3npkk4a87qqfnz0nlr7k1zjfc2s2wzbi7a94cc" ]
      [ "30.0.0.154" "14p0lcj8x09ivk1h786mj0plzz2lkvxkbw3w15fym7pd0nancz88" ]
      [ "31.0.0.108" "06kvwlzw2bjkcxzd1qvrdvlp0idvm54d1rhzn5vq1vqdhs0lnv76" ]
      [ "31.0.0.122" "1rnxqw8kn96cqf821fl209bcmqva66j2p3wq9x4d43d8lqmsazhv" ]
      [ "32.0.0.171" "1zln5m82va44nzypkx5hdkq6kk3gh7g4sx3q603hw8rys0bq22bb" ]
      [ "32.0.0.293" "08igfnmqlsajgi7njfj52q34d8sdn8k88cij7wvgdq53mxyxlian" ]
    ];
  in {
    flashplayer = let
        curFlashVer = super.lib.getVersion super.flashplayer;
      in if builtins.hasAttr curFlashVer flashSrcs
        then super.flashplayer.overrideAttrs (oldAttrs: rec {
          src = extractNPAPIFlash curFlashVer;
        })
        else super.flashplayer;
    flashplayer-standalone = let
        curFlashVer = super.lib.getVersion super.flashplayer-standalone;
      in if builtins.hasAttr curFlashVer flashSrcs
        then super.flashplayer-standalone.overrideAttrs (oldAttrs: rec {
          src = extractStandaloneFlash curFlashVer;
        })
        else super.flashplayer-standalone;
    # Helper so you can do e.g. `nix-prefetch-flash 30.0.0.134` to prefetch
    # and get the sha256 hash
    nix-prefetch-flash = super.writeScriptBin "nix-prefetch-flash" ''
        #!${super.dash}/bin/dash
        url="${mkFlashUrl "$1"}"
        nix-prefetch-url "$url"
      '';
  };

  # Equivalents to nixos-help for nix and nixpkgs manuals
  dochelpers = self: super: let
    writeHtmlHelper = name: htmlPath: super.writeScriptBin name /*ft=sh*/''
      #!${super.bash}/bin/bash
      browser="$(
        IFS=: ; for b in $BROWSER; do
          [ -n "$(type -P "$b" || true)" ] && echo "$b" && break
        done
      )"
      if [ -z "$browser" ]; then
        browser="$(type -P xdg-open || true)"
        if [ -z "$browser" ]; then
          browser="$(type -P w3m || true)"
          if [ -z "$browser" ]; then
            echo "$0: unable to start a web browser; please set \$BROWSER"
            exit 1
          fi
        fi
      fi
      $browser ${htmlPath}
    '';
  in {
    nix-help = let
      # TODO: Look into building the manual from source instead of using the
      # prebuilt version distributed in the source-distribution-tarball that
      # the Nix derivation is built from?
      nixSrc = super.nix.src;
      manual = super.runCommand "nix-manual-source" {
      } ''
        mkdir -p $out/share/doc/nix
        tar xvf ${nixSrc}
        mv nix-*/doc/manual/* $out/share/doc/nix/
      '';
    in writeHtmlHelper "nix-help" "${manual}/share/doc/nix/manual.html";
    nixpkgs-help = let
      # NOTE: There are some interesting variables to extend or overwrite to
      # affect the produced style:
      # - HIGHLIGHTJS (env, string)
      # - xlstFlags (list)
      # - XMLFORMT_CONFIg (maybe?)
      manual = super.callPackage (super.path + /doc) { };
    in writeHtmlHelper "nixpkgs-help" "${manual}/share/doc/nixpkgs/manual.html";
  };
}
