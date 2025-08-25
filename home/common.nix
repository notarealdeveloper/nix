{ lib, config, user, ...}:

{
  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
  news.display = "silent";
}
