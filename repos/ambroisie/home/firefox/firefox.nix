{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.firefox;
in
{
  config.programs.firefox = lib.mkIf cfg.enable {
    enable = true;

    package = pkgs.firefox.override {
      cfg = {
        enableTridactylNative = cfg.tridactyl.enable;
      };

      extraNativeMessagingHosts = with pkgs; ([ ]
        # Watch videos using mpv
        ++ lib.optional cfg.ff2mpv.enable ambroisie.ff2mpv-go
      );
    };

    profiles = {
      default = {
        id = 0;

        settings = {
          "browser.bookmarks.showMobileBookmarks" = true; # Mobile bookmarks
          "browser.download.useDownloadDir" = false; # Ask for download location
          "browser.in-content.dark-mode" = true; # Dark mode
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false; # Disable top stories
          "browser.newtabpage.activity-stream.feeds.sections" = false;
          "browser.newtabpage.activity-stream.feeds.system.topstories" = false; # Disable top stories
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = false; # Disable pocket
          "extensions.pocket.enabled" = false; # Disable pocket
          "media.eme.enabled" = true; # Enable DRM
          "media.gmp-widevinecdm.visible" = true; # Enable DRM
          "media.gmp-widevinecdm.enabled" = true; # Enable DRM
          "signon.autofillForms" = false; # Disable built-in form-filling
          "signon.rememberSignons" = false; # Disable built-in password manager
          "ui.systemUsesDarkTheme" = true; # Dark mode
        };
      };
    };

    extensions = with pkgs.nur.repos.rycee.firefox-addons; ([
      bitwarden
      form-history-control
      https-everywhere
      i-dont-care-about-cookies
      reddit-enhancement-suite
      ublock-origin
    ]
    ++ lib.optional (cfg.tridactyl.enable) tridactyl
    ++ lib.optional (cfg.ff2mpv.enable) ff2mpv
    );
  };
}
