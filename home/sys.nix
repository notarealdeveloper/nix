# ------------------------------------------
# all content can be divided into six types.
# ------------------------------------------
#  u  g  o: columns defined as in unix chmod
# ------------------------------------------
# 1. rw rw rw: pure wiki, almost nonexistent
# 2. rw rw r-: open source team
# 3. rw rw --: closed source team
# 4. rw r- r-: open source personal
# 5. rw r- --: closed source personal
# 6. rw -- --: closed source secret
#
# note: the execute bit is not included
# because it isn't real, citation here:
# https://youtu.be/o5cASgBEXWY&t=240
#
# this type system is sufficient for most
# practical purposes to distinguish all the
# different permission levels in a typical
# developer's life. in what follows, when
# we refer to "the rw rw r- parts of life"
# etc, we're referring to a repo with the
# scope described in the list above.

let

  HOME = builtins.getEnv("HOME");

  dst = "${HOME}/src";

  src = {

    # system
    nix = "https://github.com/notarealdeveloper/nix";

    # team stuff: the "rw rw r-" parts of life
    #
    # note: it is an exercise for the reader to
    # determine why a group called thedynamiclinker
    # would choose the name exec to refer to their
    # shared code
    exec = "https://github.com/thedynamiclinker/exec";

    # personal stuff: the "rw r- r-" parts of life
    #
    # note: this is private in the sense of being specific
    # to my workflow but not the workflow of others. this
    # sense of the term "personal" is not to be confused
    # with the sense that means "secret". for that stuff,
    # see the note below, and the file it points to.
    personal = "https://github.com/notarealdeveloper/personal";

    # secret stuff: the "rw -- --" parts of life
    #
    # are fetched in private.nix, but before doing
    # so we have to `gh auth login` with two-factor
    # secrets that (obviously) aren't stored in there
    # public text files.
    # requires auth
    secret = "https://github.com/notarealdeveloper/secret";

    # requires auth
    legacy = "https://github.com/notarealdeveloper/legacy";

  };

  sys = builtins.mapAttrs (k: v: { src = v; dst = "${dst}/${k}"; }) src;


in {

  inherit sys;

}
