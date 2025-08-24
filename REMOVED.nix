### COMMON

    /*
    fastapi = pyprev.fastapi.overrideAttrs (old: {
      propagatedBuildInputs = prev.lib.remove prev.mercurial old.propagatedBuildInputs;
    });

    poetry-core = pyprev.poetry-core.overridePythonAttrs (old: {
      doCheck = false;
    });

    sphinx = pyprev.sphinx.overridePythonAttrs (old: {
      doCheck = false;
    });

    hypothesis = pyprev.hypothesis.overridePythonAttrs (old: {
      doCheck = false;
    });

    jedi = pyprev.jedi.overridePythonAttrs (old: {
      doCheck = false;
    });

    fs = pyprev.fs.overridePythonAttrs (old: {
      doCheck = false;
    });

    pybind11 = pyprev.pybind11.overridePythonAttrs (old: {
      doCheck = false;
    });

    virtualenv = pyprev.virtualenv.overridePythonAttrs (old: {
      doCheck = false;
    });

    typeguard = pyprev.typeguard.overridePythonAttrs (old: {
      doCheck = false;
    });

    pytest-mock = pyprev.pytest-mock.overridePythonAttrs (old: {
      doCheck = false;
    });

    websockets = pyprev.websockets.overridePythonAttrs (old: {
      disabledtestpaths = (old.disabledtestpaths or []) ++ [
        "tests/sync/test_connection.py"
        "tests/legacy/test_client_server.py"
      ];
    });

    cmarkgfm = pyprev.cmarkgfm.overridePythonAttrs (old: {
      env = (old.env or {}) // {
        CFLAGS = prev.lib.concatStringsSep " " [
          (old.env.CFLAGS or "")
          "-U Py_LIMITED_API"
        ];
      };
    });

    pytest-regressions = pyprev.pytest-regressions.overridePythonAttrs (old: {
      doCheck = false;
      disabledtestpaths = (old.disabledtestpaths or []) ++ [
        "tests/test_image_regression.py"
      ];
      preCheck = (old.preCheck or "") + ''
        export HOME=$TMPDIR
        export MPLCONFIGDIR=$TMPDIR/mpl
        mkdir -p "$MPLCONFIGDIR"
        export MPLBACKEND=Agg
      '';
    });

    rich = pyprev.rich.overridePythonAttrs (old: {
      disabledTestPaths = (old.disabledTestPaths or []) ++ [
        "tests/test_inspect.py"
        "tests/test_pretty.py"
        "tests/test_text.py"
      ];
    });

    executing = pyprev.executing.overridePythonAttrs (old: {
      disabledTestPaths = (old.disabledTestPaths or []) ++ [
        "tests/test_main.py"
        "tests/test_pytest.py"
      ];
    });

    watchdog = pyprev.watchdog.overridePythonAttrs (old: {
      disabledTestPaths = (old.disabledTestPaths or []) ++ [
        "tests/test_inotify_c.py"
        "tests/test_isolated.py"
        "tests/test_logging_event_handler.py"
      ];
    });

    distutils = pyprev.distutils.overridePythonAttrs (old: {
      disabledTestPaths = (old.disabledTestPaths or []) ++ [
        "distutils/tests/test_filelist.py"
      ];
    });

    paramiko = pyprev.paramiko.overridePythonAttrs (old: {
      pythonImportsCheckPhase = "";
    });

    pynacl = pyprev.pynacl.overridePythonAttrs (old: {
      src = prev.fetchFromGitHub {
        owner = "pyca";
        repo = "pynacl";
        rev = "b712d60990092eaf58f3b5ff5858f904dd8159f4";
        hash = "sha256-UQHHVfGcgfr7nrqZ2o60bTs4BDAlSxEy6/9tNpkeHoY=";
      };

      patchPhase = "";

    #  disabledTestPaths = (old.disabledTestPaths or []) ++ [
    #    "tests/test_aead.py"
    #    "tests/test_bindings.py"
    #    "tests/test_box.py"
    #    "tests/test_encoding.py"
    #    "tests/test_generichash.py"
    #    "tests/test_hash.py"
    #    "tests/test_hashlib_scrypt.py"
    #    "tests/test_kx.py"
    #    "tests/test_public.py"
    #    "tests/test_pwhash.py"
    #    "tests/test_sealed_box.py"
    #    "tests/test_secret.py"
    #    "tests/test_secretstream.py"
    #    "tests/test_shorthash.py"
    #    "tests/test_signing.py"
    #    "tests/test_utils.py"
    #  ];

    });

    lxml = pyprev.lxml.overridePythonAttrs (old: {
      src = prev.fetchFromGitHub {
        owner = "lxml";
        repo = "lxml";
        rev = "7809707d0b28b2b147450835067ac444071182ab";
        hash = "sha256-dfIxIcWbBoOjvxkDRQm5asYsqjsQ4kvDv5AUyFILmIQ=";
      };
    });

    ruamel-yaml-clib = pyprev.ruamel-yaml-clib.overridePythonAttrs (old: {
      doCheck = false;
    });
    */

    /*
    html5lib = pyprev.html5lib.overridePythonAttrs (old: {
      doCheck = false;
      postPatch = ''
        # In Python 3.15, ast.Str is gone; string literals are ast.Constant with .value
        substituteInPlace setup.py \
          --replace-warn "isinstance(a.value, ast.Str)" "isinstance(a.value, ast.Constant)" \
          --replace-warn "a.value.s" "a.value.value"
      '';
    });

    pure-eval = pyprev.pure-eval.overridePythonAttrs (old: {
      doCheck = false;
      postPatch = ''
				cat > pure_eval/my_getattr_static.py <<- 'EOF'
				from inspect import getattr_static  # use the stdlib implementation
				__all__ = ["getattr_static"]
				EOF
			'';
    });

    traitlets = pyprev.traitlets.overridePythonAttrs (old: {
      doCheck = false;
      postPatch = ''
        # Escape % in trait.help so argparse doesn't choke
        sed -i \
          -e 's/help=trait.help/help=(trait.help or "").replace("%","%%")/' \
          -e 's/help_text=trait.help/help_text=(trait.help or "").replace("%","%%")/' \
          traitlets/config/argcomplete_config.py
      '';
    });

    # pr: ast.Str no longer exists in python>=3.14
    asttokens = pyprev.asttokens.overridePythonAttrs (old: {
      doCheck = false;
      postPatch = ''
        # In Python 3.15, ast.Str is gone; string literals are ast.Constant with .value
        substituteInPlace tests/test_asttokens.py \
          --replace-warn "isinstance(n, ast.Str)" "isinstance(n, ast.Constant)"
      '';
    });

    # pr: ast.Str no longer exists in python>=3.14
    astor = pyprev.astor.overridePythonAttrs (old: {
      disabledTestPaths = (old.disabledTestPaths or []) ++ [
        "tests/test_code_gen.py"
      ];
    });

    blinker = pyprev.blinker.overridePythonAttrs (old: {
      doCheck = false;
      #disabledTestPaths = (old.disabledTestPaths or []) ++ [
      #  "tests/test_context.py"
      #  "tests/test_symbol.py"
      #  "tests/test_signals.py"
      #];
    });

    exceptiongroup = pyprev.exceptiongroup.overridePythonAttrs (old: {
      disabledTestPaths = (old.disabledTestPaths or []) ++ [
        "tests/test_exceptions.py"
      ];
    });

    pyfakefs = pyprev.pyfakefs.overridePythonAttrs (old: {
      disabledTestPaths = (old.disabledTestPaths or []) ++ [
        "pyfakefs/tests/fake_open_test.py"
        "pyfakefs/tests/fake_filesystem_glob_test.py"
      ];
    });

    aiosignal = pyprev.aiosignal.overridePythonAttrs (old: {
      doCheck = false;
      #disabledTestPaths = (old.disabledTestPaths or []) ++ [
      #  "tests/test_signals.py"
      #];
    });

    pendulum = pyprev.pendulum.overridePythonAttrs (old: {
      env.PYO3_USE_ABI3_FORWARD_COMPATIBILITY = true;
    });

    pydantic-core = pyprev.pydantic-core.overridePythonAttrs (old: {
      src = prev.fetchFromGitHub {
        owner = "pydantic";
        repo = "pydantic-core";
        rev = "e0bc980764ec5d5f59c7d451948df937b5a1921f";
        hash = "sha256-pBds7mCRoz5T6pI2V99qaXByEzwGqnBfzSEpGXjurqM=";
      };

      cargoSha256 = "";

      env.PYO3_USE_ABI3_FORWARD_COMPATIBILITY = true;
      doCheck = false;
    });

    eventlet = pyprev.eventlet.overridePythonAttrs (old: {
      doCheck = false;
    });

    seaborn = pyprev.eventlet.overridePythonAttrs (old: {
      doCheck = false;
    });

    matplotlib = pyprev.matplotlib.overridePythonAttrs (old: {
      disabledTestPaths = (old.disabledTestPaths or []) ++ [
        "tests/test_image_regression.py"
      ];
      preCheck = (old.preCheck or "") + ''
        export MPLCONFIGDIR="$$(mktemp -d)"
      '';
      doCheck = false;
    });

    defusedxml = pyprev.defusedxml.overridePythonAttrs (old: {
      doCheck = false;
    });
    */

    /*

    # Just the diabled tests part is removed here

    ipython = pyprev.ipython.overridePythonAttrs (old: {

      src = prev.fetchFromGitHub {
        owner = "ipython";
        repo = "ipython";
        rev = "ad948680afaefee8cf530052807e2367db3826b3";
        hash = "sha256-ywi9dUDLikxPkBqYefslsEqJMK0/T5WxP6xycm7QXxg=";
      };

      disabledTestPaths = (old.disabledTestPaths or []) ++ [
        "tests/test_run.py" # only fails on free threading?
        "tests/test_oinspect.py"
        "tests/test_text.py"
        "tests/test_pretty.py"
        "tests/test_pycolorize.py"
        "tests/test_debugger.py"
        "tests/test_completer.py"
        "tests/test_interactiveshell.py"
        "tests/test_sysinfo.py"
        "IPython/utils/sysinfo.py"
        "IPython/extensions/tests/test_deduperreload.py"
      ];
    });
    */

    /*

    # Only the commented out bits are removed here
    pandas = pyprev.pandas.overridePythonAttrs (old: rec {
      version = "2.3.2";
      pyproject = true;
      src = prev.fetchFromGitHub {
        owner = "pandas-dev";
        repo = "pandas";
        rev = "188b2dae7df85a9c9945db39c5a23d23b1d4ce2e";
        hash = "sha256-Q18XQjpK1O0DpKfrNxbd0iikWl2eIQdW/b+VNIXxlKE=";
      };
      env = (old.env or {}) // { VERSIONEER_OVERRIDE = version; };
      patches = [];
      postPatch = ''
        substituteInPlace pyproject.toml \
          --replace-fail "==" ">="

        # You don't need a dynamic version, asshole
        sed -i "/^dynamic.*$/,/]/c\version = '${version}'" pyproject.toml

        echo "__version__ = '${version}'" > _version_meson.py

        # As soon as they mention this "versioneer" bullshit,
        # delete everything else in their pyproject.toml out of spite
        #sed -i "/tool.versioneer/,/\$\$/c/" pyproject.toml
        #cat pyproject.toml

        # Create a simpler generate_version.py, because their
        # dumb meson shit wants to call it
        #
        # This doesn't work for some reason
        # sed -i "s@^main[(][)]@@" generate_version.py
        # printf '\ndef main():\n    print("${version}")\n\nmain()\n' >> generate_version.py
        #
        # Ah, much better.
        #printf '#!${prev.python3}/bin/python\nprint("${version}")\n' > generate_version.py
        #chmod +x generate_version.py
        #cat generate_version.py
        #echo "HERE WE GO"
        #./generate_version.py
        #echo "LOOKS GOOD, BUILDING PANDAS"
      '';
    });

  */

### FREETHREADING ONLY

    /*
    # requests: tests pull in gevent, which isn't freethread safe yet
    requests = pyprev.requests.overridePythonAttrs (old: {
      doCheck = false;
    });
    */

    /*
    cffi = pyprev.cffi.overridePythonAttrs (old: {
      # make the build clearly t-aware
      env = (old.env or {}) // {
        NIX_CFLAGS_COMPILE =
          ((old.env.NIX_CFLAGS_COMPILE or "")
            + " -UPy_LIMITED_API -DPy_GIL_DISABLED=1");
      };

      # make the per-test mini-compiles less brittle on t headers
      postPatch = (old.postPatch or "") + ''
        # cffi's ffiplatform adds -Werror to all test compiles; drop it for t-builds
        substituteInPlace src/cffi/ffiplatform.py \
          --replace "'-Werror', " "" \
          --replace ", '-Werror'" ""
      '';

      # skip the parts that still rely on GIL-era assumptions
      disabledTestPaths = (old.disabledTestPaths or []) ++ [
        "testing/cffi1/test_new_ffi_1.py"
        "testing/cffi1/test_recompiler.py"
        "testing/cffi1/test_verify1.py"
        "testing/cffi1/test_ffi_obj.py"     # only fails on 313t
        "testing/cffi1/test_zdist.py"       # only fails on 313t
      ];

      # this is PROBABLY working without doCheck = false here,
      # but need to wait until overnight or something to try
      # building it this way on all interpreters. get that
      # binary cache set up soon!
      doCheck = false;
    });
    */
