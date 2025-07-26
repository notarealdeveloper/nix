pkgs:

  (pkgs.python311.withPackages (ps: with ps; [
    pip
    setuptools
    ipython
    numpy
    pandas
    scikit-learn
    lightgbm
    lambda-multiprocessing
    tflite-runtime
  ]))
