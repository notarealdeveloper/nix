{
  lib,
  fetchFromGitHub,

  # python dependencies
  buildPythonPackage,
  setuptools,
  wheel,

  # non-python dependencies
  hello,
}:

buildPythonPackage rec {
  pname = "jello";
  version = "1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "notarealdeveloper";
    repo = "jello";
    rev = "18d6bc75b6d16133ca8b5ebd3db486da36cbecc9";
    sha256 = "sha256-rnNoGpyab8bbaRA/QuZRIOolv+FTrCGf++IBayVQUMM=";
  };

  build-system = [ setuptools wheel ];

  dependencies = [
    hello
  ];

  buildInputs = [
    hello
  ];

  # Ensure that there are no undeclared deps
  postCheck = ''
    PATH= PYTHONPATH= $out/bin/hello
  '';

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      hello
    ])
  ];

  #meta = with lib; {
  #  changelog = "https://github.com/pypa/auditwheel/blob/${version}/CHANGELOG.md";
  #  description = "Auditing and relabeling cross-distribution Linux wheels";
  #  homepage = "https://github.com/pypa/auditwheel";
  #  license = with licenses; [
  #    mit # auditwheel and nibabel
  #    bsd2 # from https://github.com/matthew-brett/delocate
  #    bsd3 # from https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-projects/pax-utils/lddtree.py
  #  ];
  #  mainProgram = "auditwheel";
  #  maintainers = with maintainers; [ davhau ];
  #  platforms = platforms.linux;
  #};
}
