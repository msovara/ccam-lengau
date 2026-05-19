#!/bin/bash
# Resume CCAM suite build from g2n onward (after globpea..cdfvidar succeeded).
# Builds g2n deps (Jasper + g2lib) then remaining serial tools.

set -e

SUITE_SRC="${SUITE_SRC:-/mnt/lustre/users/msovara/SoftwareBuilds/ccam-suite}"
CCAM_SRC="${CCAM_SRC:-/mnt/lustre/users/msovara/SoftwareBuilds/ccam}"
INSTALL_BIN="${INSTALL_BIN:-/home/apps/chpc/earth/CCAM-oneapi2021.3/bin}"
NETCDF_MODULE="${NETCDF_MODULE:-chpc/earth/netcdf/4.9.2-intel2021.3}"

ONEAPI_BASE="/home/apps/chpc/compmech/compilers/intel_2021.3/oneapi"
ONEAPI_COMPILER="${ONEAPI_BASE}/compiler/2021.3.0/env/vars.sh"
ONEAPI_MPI="${ONEAPI_BASE}/mpi/2021.3.0/env/vars.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== CCAM suite resume (g2n + remaining) ==="
echo "INSTALL_BIN=$INSTALL_BIN"
echo ""

mkdir -p "$INSTALL_BIN"

module purge
source "$ONEAPI_COMPILER"
source "$ONEAPI_MPI"
module load "$NETCDF_MODULE"
export PATH="${ONEAPI_BASE}/compiler/2021.3.0/linux/bin/intel64:${ONEAPI_BASE}/mpi/2021.3.0/bin:${PATH}"

NETCDF_PREFIX=$(nc-config --prefix)
export NETCDF_ROOT="$NETCDF_PREFIX"
export NETCDF="$NETCDF_PREFIX"
export SUITE_SRC CCAM_SRC INSTALL_BIN

"$SCRIPT_DIR/build_g2n_deps_lengau.sh"

build_serial() {
  local dir=$1
  local exe=$2
  if [[ ! -d "$SUITE_SRC/$dir" ]]; then
    echo "SKIP $exe: $SUITE_SRC/$dir not found"
    return 0
  fi
  if [[ -x "$INSTALL_BIN/$exe" ]]; then
    echo "SKIP $exe: already in $INSTALL_BIN"
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

build_serial g2n g2n
build_serial igbpveg igbpveg
build_serial terread terread
build_serial ocnbath ocnbath
build_serial sibveg sibveg
build_serial casafield casafield
build_serial smclim smclim || echo "WARN: smclim optional (not built)"

echo ""
echo "=== Resume build finished ==="
ls -la "$INSTALL_BIN"
