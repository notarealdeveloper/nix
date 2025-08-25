# private.nix
#
# the type system described in system.nix
# referred to certain types as "secret"
#
# the secrets in question
# can be further subdivided into two sub-types:
#
# a. real secrets
# b. serious secrets
#
# real secrets are the things you'd never
# put anywhere remote, no matter how secure
# that remote place claimed to be.
# real secrets are things like:
#
# 1. private keys to your local bitcoins,
# 2. any files detailing the highly illegal
#    activities you've been engaged in,
#    whether non-executable (~/terror.txt)
#    or executable (~/bin/laden).
# 3. naked pictures of your mom.
#    (not my mom. (i mean your mom.
#    (i mean i've got to keep them
#    (somewhere.))))
#
# serious secrets, on the other hand, are
# all the sooper serious bullshit secrets
# we're all required to keep track of these
# days as a punishment for being alive.
# because these secrets are s(u|oo)per srs,
# secrets of this type can and should be
# tossed around into any reasonably corporate
# sounding or somewhat trustworthy-ish remote
# storage service without losing sleep.
#
# it is these latter kind of less important
# secrets to which the term "secret" refers
# below. tl;dr: don't worry. your mom's
# pictures are safe.

{ pkgs, lib, config, ... }:

let

  src = import ./src.nix { };
  inherit (src) secret legacy;

  link = config.lib.file.mkOutOfStoreSymlink;

in

{

  # git clone private repos
  home.activation.clonePrivate = lib.hm.dag.entryAfter ["writeBoundary" "installPackages"] ''

    export PATH="${pkgs.git}/bin:$PATH"

    if [ ! -d "${secret.dst}" ]; then
      git clone "${secret.src}" "${secret.dst}"
    fi

    if [ ! -d "${legacy.dst}" ]; then
      git clone "${legacy.src}" "${legacy.dst}"
    fi

  '';

  home.file = lib.mkMerge [{
    # sooper serious secrets zomg
    ".pypirc".source    = link "${secret.dst}/etc/pypirc";
    ".netrc".source     = link "${secret.dst}/etc/netrc";
    ".ssh".source       = link "${secret.dst}/etc/ssh";

    # gitlab
    ".config/glab-cli/config.yml".source = link "${secret.dst}/etc/glab-cli-config.yml";
  }];

  # PATH for interactive shells
  # home.sessionVariables.PATH = lib.mkBefore "${secret.dst}/bin";

  # PATH for login shells
  home.sessionPath = [
    "${secret.dst}/bin"
  ];

  programs.bash = {
    enable = true;
    bashrcExtra = lib.mkAfter ''
      source "${secret.dst}/etc/bashrc"
    '';
  };
}
