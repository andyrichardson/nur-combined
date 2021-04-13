{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "auto-tab-discard";
  url = "https://addons.mozilla.org/firefox/downloads/file/3755275/auto_tab_discard-0.4.3-an+fx.xpi";
  sha256 = "sha256-Y+n3Le2sofGAmJ89xrqu6cFMJD3+V8OdoB8wm8OgG2w=";

  # meta = with lib; {
  #   # https://github.com/rNeomy/auto-tab-discard
  #   homepage = "https://add0n.com/tab-discard.html/";
  #   description = "Addon that uses native tab discarding method to automatically reduce memory usage of inactive tabs";
  #   longDescription = ''
  #     A browser extension which uses the native tab discarding method
  #     (chrome.tabs.discard) to automatically reduce memory usage of inactive
  #     tabs.
  #     This extension is more efficient and should be less buggy compared to the
  #     alternatives extensions that use DOM replacement method.
  #   '';
  #   license = licenses.mpl20;
  #   maintainers = with maintainers; [ jk ];
  # };
}
