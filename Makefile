# MIT License

# Copyright (c) 2026 SimBricks

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Compilers and python interpreter (overridable by conda / the environment).
CXX               ?= c++
PYTHON            ?= python

# Where "make e1000-install" places the binary. Inside a conda build this is the
# host/build prefix; for a local dev build override it, e.g. PREFIX=$(pwd)/out.
PREFIX            ?= $(CURDIR)/out
# simbricks-lib install layout: the headers and the static libs the behavioral
# model links against. Default under PREFIX; override for local dev to
# wherever simbricks-lib is installed.
SIMBRICKS_INC_DIR ?= $(PREFIX)/include
SIMBRICKS_LIB_DIR ?= $(PREFIX)/lib/simbricks

# Python packages (each has its own pyproject.toml).
E1000_PY_SIM       := e1000_sim_bm_py
E1000_PY_SYS       := e1000_sys_py

# Optional: redirect conda-build output, e.g. OUTPUT_FOLDER=./conda-out.
OUTPUT_FOLDER     ?=
OUTPUT_FLAG       := $(if $(OUTPUT_FOLDER),--output-folder $(OUTPUT_FOLDER))
# Conda channels searched by `conda build`. The SimBricks channel hosts external
# deps not built here (e.g. simbricks-lib, simbricks-orchestration); conda-forge
# provides the rest. Override to point at a different channel if needed.
SIMB_CONDA_CHANNEL:= -c https://conda.simbricks.io/latest
BASE_BUILD_CMD    := conda build $(SIMB_CONDA_CHANNEL) -m conda-recipes/conda_build_config.yaml $(OUTPUT_FLAG)

.PHONY: all \
        e1000-build e1000-install \
        e1000-python-develop \
        e1000-sys-py-conda e1000-sim-bm-py-conda e1000-sim-bm-bin-conda \
        conda-packages pypi-build pypi-publish clean

## --- e1000_gem5 behavioral model (C++ sources in e1000_gem5/) --------------

# Standalone dev build: just the binary, no conda package. The compile rules
# live in e1000_gem5/Makefile (a self-contained makefile); we only drive them.
e1000-build:
	$(MAKE) -C e1000_gem5 all CXX="$(CXX)" \
	    SIMBRICKS_INC_DIR="$(SIMBRICKS_INC_DIR)" \
	    SIMBRICKS_LIB_DIR="$(SIMBRICKS_LIB_DIR)"

# Install the binary into $(PREFIX)/sims/nic/e1000_gem5/e1000_gem5 (builds first
# via the dependency; the install step itself only needs PREFIX).
e1000-install: e1000-build
	$(MAKE) -C e1000_gem5 install-e1000 PREFIX="$(PREFIX)"

## --- Python packages -------------------------------------------------------

# Editable installs for local development.
e1000-python-develop:
	$(PYTHON) -m pip install -e ./$(E1000_PY_SIM)
	$(PYTHON) -m pip install -e ./$(E1000_PY_SYS)

## --- Conda packages --------------------------------------------------------

e1000-sys-py-conda:
	$(BASE_BUILD_CMD) conda-recipes/simbricks-e1000-sys-py

e1000-sim-bm-py-conda: e1000-sys-py-conda
	$(BASE_BUILD_CMD) conda-recipes/simbricks-e1000-sim-bm-py

e1000-sim-bm-bin-conda:
	$(BASE_BUILD_CMD) conda-recipes/simbricks-e1000-sim-bm-bin

# Build all conda packages (python hulls first, then the compiled binary).
conda-packages: e1000-sys-py-conda e1000-sim-bm-py-conda e1000-sim-bm-bin-conda

## --- PyPI packages ---------------------------------------------------------

pypi-build:
	poetry build -C $(E1000_PY_SIM)
	poetry build -C $(E1000_PY_SYS)

pypi-publish: pypi-build
	poetry publish -C $(E1000_PY_SIM)
	poetry publish -C $(E1000_PY_SYS)

## --- Default target ----------------------------------------------------------

# Default: local dev build of both halves.
all: conda-packages

## --- Housekeeping ----------------------------------------------------------

clean:
	-$(MAKE) -C e1000_gem5 clean
	rm -rf $(E1000_PY_SIM)/dist $(E1000_PY_SYS)/dist
