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

    mkkan() {
      yt-dlp -P "$HOME/daxingxing" -o "$1.%(ext)s" "$2"
    }

    mkkan happy      https://www.youtube.com/watch?v=06Kg6XeMhQU
    mkkan yayomyca   https://www.youtube.com/watch?v=ZZiTNJ6QleA
    mkkan cawoomwoom https://www.youtube.com/watch?v=B1u-ylQR6Fo
    mkkan eieio      https://www.youtube.com/watch?v=_6HzoUcx3eo

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

  home.sessionVariables.PATH = "$HOME/bin:$HOME/.local/bin:$PATH";

  # Keep this line
  home.stateVersion  = "25.05";

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
}
