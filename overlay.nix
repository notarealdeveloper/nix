# overlay.nix
final: prev: {
  sl2 = prev.sl.overrideAttrs (_: {
    src = prev.fetchFromGitHub {
      owner = "mtoyoda";
      repo  = "sl";
      rev   = "923e7d7ebc5c1f009755bdeb789ac25658ccce03";
      sha256  = "173gxk0ymiw94glyjzjizp8bv8g72gwkjhacigd1an09jshdrjb4";
    };
  });
}
