{ pkgs, lib, config, desktop ? true, ... }:

let

  user = "luna";
  common = (import ./common.nix user);

in

{

  imports = [
    common
    ./lib/public.nix
    (if desktop then ./lib/desktop.nix else ./lib/none.nix)
  ];

  home.packages = with pkgs; [
    yt-dlp
    vlc
  ];

  home.activation.prepareDaXingXing = lib.hm.dag.entryAfter ["writeBoundary" "installPackages"] ''

    export PATH="${pkgs.yt-dlp}/bin:$PATH"

    mkdir -pv "${config.home.homeDirectory}/bin"
    mkdir -pv "${config.home.homeDirectory}/daxingxing"

    mkkan() {
      yt-dlp -P "$HOME/daxingxing" -o "$1.%(ext)s" "$2"
    }

    mkkan yayomyca   https://www.youtube.com/watch?v=ZZiTNJ6QleA
    mkkan cawoomwoom https://www.youtube.com/watch?v=B1u-ylQR6Fo
    mkkan driving    https://www.youtube.com/watch?v=BdrZWu2dZ4c
    mkkan eieio      https://www.youtube.com/watch?v=_6HzoUcx3eo
    mkkan happy      https://www.youtube.com/watch?v=06Kg6XeMhQU
    mkkan babyshark  https://www.youtube.com/watch?v=XqZsoesa55w
    mkkan putshoes   https://www.youtube.com/watch?v=D_FGBpQ0iOg
    mkkan sunnyday   https://www.youtube.com/watch?v=CEFL-4weVsI
    mkkan abcquack   https://www.youtube.com/watch?v=I_3mbra4dHU
    mkkan monster    https://www.youtube.com/watch?v=JC29ZvTkBT0
  '';

  home.file."bin/kan" = {
    text = ''
      #!/usr/bin/env bash
      songs=("$(find "$HOME/daxingxing" | sort -R)")
      exec vlc ''${songs[*]} 2> $HOME/.kan.log
    '';
    executable = true;
  };

  # add ~/bin to PATH persistently
  home.sessionPath = [ "$HOME/bin" ];

  home.sessionVariables.PATH = "$HOME/bin:$HOME/.local/bin:$PATH";

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      export PATH="$HOME/bin:$PATH"
    '';
  };

  # Keep this line
  home.stateVersion  = "25.05";

}
