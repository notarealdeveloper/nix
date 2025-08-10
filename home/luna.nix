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
    weatherspect
  ];

  home.activation.prepareDaXingXing = lib.hm.dag.entryAfter ["writeBoundary" "installPackages"] ''

    export PATH="${pkgs.yt-dlp}/bin:$PATH"

    mkdir -pv "${config.home.homeDirectory}/bin"
    mkdir -pv "${config.home.homeDirectory}/daxingxing"

    mkkan() {
      local name="$1"
      local url="$2"
      if [[ $(ls daxingxing/ | grep -P "^$name[.](mp4|webm)" | wc -l) > 0 ]]; then
        echo "Already have kan: $1"
      else
        echo "Making kan: $1"
        yt-dlp -P "$HOME/daxingxing" -o "$name.%(ext)s" "$url"
      fi
    }

    mkkan yayomyca      https://www.youtube.com/watch?v=ZZiTNJ6QleA
    mkkan cawoomwoom    https://www.youtube.com/watch?v=B1u-ylQR6Fo
    mkkan driving       https://www.youtube.com/watch?v=BdrZWu2dZ4c
    mkkan eieio         https://www.youtube.com/watch?v=_6HzoUcx3eo
    mkkan happy         https://www.youtube.com/watch?v=06Kg6XeMhQU
    mkkan babyshark     https://www.youtube.com/watch?v=XqZsoesa55w
    mkkan putshoes      https://www.youtube.com/watch?v=D_FGBpQ0iOg
    mkkan sunnyday      https://www.youtube.com/watch?v=CEFL-4weVsI
    mkkan bflylbugbbee  https://www.youtube.com/watch?v=EgiQ6GliTrI
    mkkan abcquack      https://www.youtube.com/watch?v=I_3mbra4dHU
    mkkan abcshark      https://www.youtube.com/watch?v=ccEpTTZW34g
    mkkan abchop        https://www.youtube.com/watch?v=w2DZA3mfAUU
    mkkan rygb          https://www.youtube.com/watch?v=6PyYx255Qcg
    mkkan beddybye      https://www.youtube.com/watch?v=ij_eHTvhIlE
    mkkan monster       https://www.youtube.com/watch?v=JC29ZvTkBT0
    mkkan ifyoulike     https://www.youtube.com/watch?v=UXt2bNp77u0
    mkkan teninthebed   https://www.youtube.com/watch?v=fu_xY9kMSBU
    mkkan wheelsonbus   https://www.youtube.com/watch?v=AvJAzwCGQKw
    mkkan crawllikea    https://www.youtube.com/watch?v=PoZdClg4SQc
    mkkan whocookie     https://www.youtube.com/watch?v=Vu0-98fgnRo
    mkkan areyouhungry  https://www.youtube.com/watch?v=vACFjPUFHM4
    mkkan thisisahappy  https://www.youtube.com/watch?v=W9rX6ApYqjo
    mkkan whatdoyouhear https://www.youtube.com/watch?v=YVgv1EFJZHc
    mkkan happy-orig    https://www.youtube.com/watch?v=ZbZSe6N_BXs
    mkkan uptownfunk    https://www.youtube.com/watch?v=OPf0YbXqDm0
    mkkan dancemonkey   https://www.youtube.com/watch?v=q0hyYWKXF0Q
    mkkan doremi        https://www.youtube.com/watch?v=drnBMAEA3AM
    mkkan goyte         https://www.youtube.com/watch?v=8UVNT4wvIGY
    mkkan daxingxing1   https://www.youtube.com/watch?v=bMRosz1JZOA
    mkkan daxingxing2   https://www.youtube.com/watch?v=UyqnRW-CZs4
    mkkan shakeitoff    https://www.youtube.com/watch?v=bo_gAHD-mPY
    mkkan frozendoyou   https://www.youtube.com/watch?v=TeQ_TTyLGMs
    mkkan frozen4ever   https://www.youtube.com/watch?v=ZrX1XKtShSI
    mkkan frozenletitgo https://www.youtube.com/watch?v=YVVTZgwYwVo
    mkkan frozenloveis  https://www.youtube.com/watch?v=kQDw88hEr2c
    mkkan blackbetty    https://www.youtube.com/watch?v=I_2D8Eo15wE
    mkkan gangnamstyle  https://www.youtube.com/watch?v=9bZkp7q19f0
    mkkan outkastheyya  https://www.youtube.com/watch?v=PWgvGjAhvIw
    mkkan sweetchild    https://www.youtube.com/watch?v=1w7OgIMMRc4
    mkkan lazysong      https://www.youtube.com/watch?v=fLexgOxsZu0
    mkkan arielpartof   https://www.youtube.com/watch?v=SXKlJuO07eM
    mkkan poohexercise  https://www.youtube.com/watch?v=Pm1qzfbRAPw
    mkkan poohintro     https://www.youtube.com/watch?v=eTK9x4baQY8
    mkkan poohhefwooz   https://www.youtube.com/watch?v=CLnADKgurvc
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
