# modules/dev/python.nix --- https://godotengine.org/
#
# Python's ecosystem repulses me. The list of environment "managers" exhausts
# me. The Py2->3 transition make trainwrecks jealous. But SciPy, NumPy, iPython
# and Jupyter can have my babies. Every single one.

{ config, options, lib, pkgs, my, ... }:

with lib;
with lib.my;
let devCfg = config.modules.dev;
    cfg = devCfg.python;
in {
  options.modules.dev.python = {
    enable = mkBoolOpt false;
    xdg.enable = mkBoolOpt devCfg.xdg.enable;
  };

  config = mkMerge [
    (mkIf cfg.enable {
      user.packages = with pkgs; [
        python3
        python3Packages.ipython
        # debugging
        python3Packages.ipdb
        # formatting
        python3Packages.black     # format
        python3Packages.isort     # sort imports
        python3Packages.pyflakes  # check python files for error
        python3Packages.pylint
        # packages
        python3Packages.pip
        python3Packages.setuptools
        # poetry is promoted to a top-level attribute,
        poetry
        python3Packages.numpy
      ];

      environment.shellAliases = {
     };

    })

    (mkIf cfg.xdg.enable {
      env.IPYTHONDIR      = "$XDG_CONFIG_HOME/ipython";
      env.PIP_CONFIG_FILE = "$XDG_CONFIG_HOME/pip/pip.conf";
      env.PIP_LOG_FILE    = "$XDG_DATA_HOME/pip/log";
      env.PYLINTHOME      = "$XDG_DATA_HOME/pylint";
      env.PYLINTRC        = "$XDG_CONFIG_HOME/pylint/pylintrc";
      # env.PYTHONSTARTUP   = "$XDG_CONFIG_HOME/python/pythonrc";
      env.PYTHON_EGG_CACHE = "$XDG_CACHE_HOME/python-eggs";
      env.JUPYTER_CONFIG_DIR = "$XDG_CONFIG_HOME/jupyter";
    })
  ];
}
