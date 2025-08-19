{ sl
, fetchFromGitHub
}:

sl.overrideAttrs (old: {
  pname = "sl2";
  installPhase = ''
    runHook preInstall

    mkdir -pv     $out/{bin,share/man/man1}
    mv -v sl      $out/bin/sl2
    mv -v sl.1    $out/share/man/man1/sl2.1

    runHook postInstall
  '';

  src = fetchFromGitHub {
    owner = "mtoyoda";
    repo  = "sl";
    rev   = "923e7d7ebc5c1f009755bdeb789ac25658ccce03";
    sha256  = "173gxk0ymiw94glyjzjizp8bv8g72gwkjhacigd1an09jshdrjb4";
  };
})
