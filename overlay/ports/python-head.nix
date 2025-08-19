{ stdenv
, lib
, pkg-config
, zlib
, openssl
, bzip2
, xz
, zstd
, libffi
, readline
, ncurses
, gdbm
, sqlite
, libuuid
, tk
}:

stdenv.mkDerivation {
  pname = "cpython";
  version = "head";

  src = builtins.fetchGit {
    url = "https://github.com/python/cpython";
    rev = "e39255e76d4b6755a44f6d4e63180136c778d2a5";
    shallow = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    zlib.dev
    openssl.dev
    bzip2.dev
    xz.dev
    zstd.dev
    libffi.dev
    readline.dev
    ncurses.dev
    gdbm.dev
    sqlite.dev
    libuuid.dev
    tk.dev
  ];

  buildInputs = [
    zlib
    openssl
    bzip2
    xz
    zstd
    libffi
    readline
    ncurses
    gdbm
    sqlite
    libuuid
    tk
  ];

  enableParallelBuilding = true;

  buildPhase = ''
    make -j $(nproc)
  '';

  meta = with lib; {
    description = "CPython upstream HEAD as a system package";
    license = licenses.psfl;
    platforms = platforms.unix;
  };
}

