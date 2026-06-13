{
  lib,
  buildPythonPackage,
  fetchPypi,
  flatten-dict,
  aiobotocore,
  boto3,
  dvc-objects,
  s3fs,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "dvc-s3";
  version = "3.2.2";
  pyproject = true;

  src = fetchPypi {
    pname = "dvc_s3";
    inherit version;
    hash = "sha256-Dqcsm2sADf6hqDTUEGczts3HRdCm7h1cCluMg0RnFxY=";
  };

  # Prevent circular dependency
  pythonRemoveDeps = [ "dvc" ];

  # dvc-s3 uses boto3 directly, we add in propagatedBuildInputs
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "aiobotocore[boto3]" "aiobotocore"
  '';

  build-system = [ setuptools-scm ];

  dependencies = [
    aiobotocore
    boto3
    dvc-objects
    flatten-dict
    s3fs
  ];

  doCheck = false;

  meta = with lib; {
    description = "s3 plugin for dvc";
    homepage = "https://pypi.org/project/dvc-s3/${version}";
    changelog = "https://github.com/iterative/dvc-s3/releases/tag/${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ melling ];
  };
}
