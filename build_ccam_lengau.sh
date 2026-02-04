#!/bin/bash
# Build CCAM on Lengau using Intel OneAPI (no license required).
# Run this inside an interactive PBS session on Lengau.
# Source is assumed at: /mnt/lustre/users/$USER/SoftwareBuilds/ccam
#
# Usage:
#   chmod +x build_ccam_lengau.sh
#   ./build_ccam_lengau.sh
#
# Use licensed Intel instead of OneAPI (if available):
#   USE_ONEAPI=0 ./build_ccam_lengau.sh
#
# Override location:
#   CCAM_SRC=/path/to/ccam ./build_ccam_lengau.sh

set -e

# --- Paths (override with env if needed) ---
CCAM_SRC="${CCAM_SRC:-/mnt/lustre/users/$USER/SoftwareBuilds/ccam}"
USE_ONEAPI="${USE_ONEAPI:-1}"

# OneAPI 2021.3 (compmech; no license)
ONEAPI_BASE="/home/apps/chpc/compmech/compilers/intel_2021.3/oneapi"
ONEAPI_COMPILER="${ONEAPI_BASE}/compiler/2021.3.0/env/vars.sh"
ONEAPI_MPI="${ONEAPI_BASE}/mpi/2021.3.0/env/vars.sh"

# NetCDF built for Intel 2021.3 (used with OneAPI)
NETCDF_MODULE="${NETCDF_MODULE:-chpc/earth/netcdf/4.9.2-intel2021.3}"

# Licensed Intel toolchain (only if USE_ONEAPI=0 and license available)
INTEL_MODULE="${INTEL_MODULE:-chpc/parallel_studio_xe/2020u1}"
MPI_MODULE="${MPI_MODULE:-chpc/compmech/openmpi/5.0.7-intel2020u1}"
NETCDF_MODULE_LICENSED="${NETCDF_MODULE_LICENSED:-chpc/earth/netcdf/4.7.4/intel2020u1}"

echo "=== CCAM build on Lengau ==="
echo "CCAM_SRC=$CCAM_SRC"
echo "USE_ONEAPI=$USE_ONEAPI"
if [[ "$USE_ONEAPI" = "1" ]]; then
  echo "Toolchain: OneAPI 2021.3 (compiler + MPI) + NetCDF module $NETCDF_MODULE"
else
  echo "Toolchain: Intel modules $INTEL_MODULE, $MPI_MODULE, $NETCDF_MODULE_LICENSED"
fi
echo ""

if [[ ! -d "$CCAM_SRC" ]]; then
  echo "ERROR: CCAM source not found at $CCAM_SRC"
  echo "Clone CCAM first (e.g. on DTN: module purge; git clone https://bitbucket.csiro.au/scm/CCAM/ccam.git $CCAM_SRC)"
  exit 1
fi

# --- Load environment ---
module purge

if [[ "$USE_ONEAPI" = "1" ]]; then
  if [[ ! -f "$ONEAPI_COMPILER" ]]; then
    echo "ERROR: OneAPI compiler not found at $ONEAPI_COMPILER"
    exit 1
  fi
  echo "Sourcing OneAPI compiler..."
  source "$ONEAPI_COMPILER"
  echo "Sourcing OneAPI MPI..."
  source "$ONEAPI_MPI"
  module load "$NETCDF_MODULE"
  # Keep OneAPI compiler/MPI first in PATH (NetCDF module can add gfortran mpif90)
  export PATH="${ONEAPI_BASE}/compiler/2021.3.0/linux/bin/intel64:${ONEAPI_BASE}/mpi/2021.3.0/bin:${PATH}"
  export MPIF90=mpiifort
  export FC=mpiifort
else
  module load "$INTEL_MODULE"
  module load "$MPI_MODULE"
  module load "$NETCDF_MODULE_LICENSED"
fi

echo "--- Compilers and NetCDF ---"
which ifort mpiifort mpif90 2>/dev/null || true
ifort --version 2>/dev/null | head -1
command -v nc-config >/dev/null && echo "NETCDF prefix: $(nc-config --prefix)" || echo "nc-config not in PATH"
echo ""

# --- Build ---
cd "$CCAM_SRC"
NETCDF_PREFIX=$(nc-config --prefix 2>/dev/null || true)
export NETCDF="$NETCDF_PREFIX"
export NETCDF_ROOT="$NETCDF_PREFIX"   # CCAM Makefile uses NETCDF_ROOT
# OneAPI: Makefile has FC=mpif90; pass FC=mpiifort so Makefile uses Intel (not gfortran)
if command -v mpiifort >/dev/null 2>&1; then
  export MPIF90=mpiifort
  export FC=mpiifort
  MAKE_FC="FC=mpiifort"
else
  MAKE_FC=""
fi
make clean 2>/dev/null || true
make $MAKE_FC NETCDF_ROOT="$NETCDF_PREFIX"

echo ""
echo "=== Build finished ==="
ls -la ccam 2>/dev/null || ls -la globpea 2>/dev/null || ls -la *.x 2>/dev/null || find . -maxdepth 1 -type f -executable 2>/dev/null || true
