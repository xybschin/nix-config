{ ... }:
{
  programs.brave = {
    enable = true;

    # AMD (fenris): enable VA-API so hardware video decoding works without
    # having to flip it on in brave://settings by hand.
    commandLineArgs = [
      "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder"
    ];

    # Chrome Web Store IDs.
    extensions = [
      {
        id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; # uBlock Origin
      }
      {
        id = "dbepggeogbaibhgnhhndojpepiihcmeb"; # Vimium
      }
      {
        id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; # 1Password
      }
    ];
  };
}
