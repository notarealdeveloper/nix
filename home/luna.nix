{ pkgs, lib, config, ... }:

{

  home.username = "luna";
  home.homeDirectory = "/home/luna";

  home.packages = with pkgs; [
    yt-dlp
    vlc
  ];

  # git clone repos if not present
  home.activation.prepareDaXingXing = lib.hm.dag.entryAfter ["writeBoundary" "installPackages"] ''
    export PATH="${pkgs.yt-dlp}/bin:$PATH"

    mkdir -pv "${config.home.homeDirectory}/bin"
    mkdir -pv "${config.home.homeDirectory}/daxingxing"
    chmod +x ${config.home.homeDirectory}/bin/kan

    yt-dlp -P "$HOME/daxingxing" \
      https://www.youtube.com/watch?v=06Kg6XeMhQU \
      https://www.youtube.com/watch?v=ZZiTNJ6QleA \
      https://www.youtube.com/watch?v=B1u-ylQR6Fo
  '';

  home.file."bin/kan" = {
    text = ''
      #!/bin/sh
      export PATH="${pkgs.vlc}/bin:$PATH"
      exec vlc "$HOME/daxingxing"
    '';
    executable = true;
  };

  # add ~/bin to PATH persistently
  home.sessionPath = [ "$HOME/bin" ];

  # Keep this line
  home.stateVersion  = "25.05";

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
}
