#!/bin/bash
# Build full CCAM suite on Lengau with Intel OneAPI.
# Run inside an interactive PBS session (not on login node).
#
# Prerequisites:
#   - download_ccam_suite_dtn.sh run on DTN
#   - Sources in SUITE_SRC and CCAM_SRC (see below)
#
# Usage:
#   chmod +x build_ccam_suite_lengau.sh
#   ./build_ccam_suite_lengau.sh

set -e

SUITE_SRC="${SUITE_SRC:-/mnt/lustre/users/msovara/SoftwareBuilds/ccam-suite}"
CCAM_SRC="${CCAM_SRC:-/mnt/lustre/users/msovara/SoftwareBuilds/ccam}"
INSTALL_BIN="${INSTALL_BIN:-/home/apps/chpc/earth/CCAM-oneapi2021.3/bin}"
NETCDF_MODULE="${NETCDF_MODULE:-chpc/earth/netcdf/4.9.2-intel2021.3}"

ONEAPI_BASE="/home/apps/chpc/compmech/compilers/intel_2021.3/oneapi"
ONEAPI_COMPILER="${ONEAPI_BASE}/compiler/2021.3.0/env/vars.sh"
ONEAPI_MPI="${ONEAPI_BASE}/mpi/2021.3.0/env/vars.sh"

echo "=== CCAM full suite build (OneAPI) ==="
echo "SUITE_SRC=$SUITE_SRC"
echo "CCAM_SRC=$CCAM_SRC"
echo "INSTALL_BIN=$INSTALL_BIN"
echo ""

mkdir -p "$INSTALL_BIN"

# --- OneAPI + NetCDF ---
module purge
source "$ONEAPI_COMPILER"
source "$ONEAPI_MPI"
module load "$NETCDF_MODULE"
export PATH="${ONEAPI_BASE}/compiler/2021.3.0/linux/bin/intel64:${ONEAPI_BASE}/mpi/2021.3.0/bin:${PATH}"

NETCDF_PREFIX=$(nc-config --prefix)
export NETCDF_ROOT="$NETCDF_PREFIX"
export NETCDF="$NETCDF_PREFIX"

echo "NETCDF_ROOT=$NETCDF_ROOT"
ifort --version | head -1
echo ""

# Build helper: serial Fortran (ifort)
build_serial() {
  local dir=$1
  local exe=$2
  if [[ ! -d "$SUITE_SRC/$dir" ]]; then
    echo "SKIP $exe: $SUITE_SRC/$dir not found"
    return 0
  fi
  echo "--- Building $exe in $dir ---"
  cd "$SUITE_SRC/$dir"
  make clean 2>/dev/null || true
  make FC=ifort NETCDF_ROOT="$NETCDF_PREFIX" || make FC=ifort NETCDF="$NETCDF_PREFIX"
  if [[ -f "$exe" ]]; then
    cp -f "$exe" "$INSTALL_BIN/"
    echo "OK: $INSTALL_BIN/$exe"
  else
    echo "FAIL: $exe not produced in $SUITE_SRC/$dir"
    return 1
  fi
}

# Build helper: MPI Fortran (mpiifort)
build_mpi() {
  local dir=$1
  local exe=$2
  local srcdir
  if [[ "$dir" == "ccam" ]]; then
    srcdir="$CCAM_SRC"
  else
    srcdir="$SUITE_SRC/$dir"
  fi
  if [[ ! -d "$srcdir" ]]; then
    echo "SKIP $exe: $srcdir not found"
    return 0
  fi
  echo "--- Building $exe in $srcdir ---"
  cd "$srcdir"
  make clean 2>/dev/null || true
  make FC=mpiifort NETCDF_ROOT="$NETCDF_PREFIX" || make FC=mpiifort NETCDF="$NETCDF_PREFIX"
  if [[ -f "$exe" ]]; then
    cp -f "$exe" "$INSTALL_BIN/"
    echo "OK: $INSTALL_BIN/$exe"
  else
    echo "FAIL: $exe not produced in $srcdir"
    return 1
  fi
}

# Order matches legacy ccam_compile.sh
build_mpi ccam globpea
build_serial aeroemiss aeroemiss
build_mpi pcc2hist pcc2hist
build_serial cdfvidar cdfvidar
build_serial g2n g2n
build_serial igbpveg igbpveg
build_serial terread terread
build_serial ocnbath ocnbath
build_serial sibveg sibveg
build_serial casafield casafield
build_serial smclim smclim || echo "WARN: smclim optional (not built)"

echo ""
echo "=== Build finished ==="
echo "Installed binaries in $INSTALL_BIN:"
ls -la "$INSTALL_BIN"
echo ""
echo "Load with: module load chpc/earth/ccam/oneapi2021.3"
echo "Static data (vegin, ccamdata) may still use: /home/apps/chpc/earth/CCAM/ccaminstall/"
