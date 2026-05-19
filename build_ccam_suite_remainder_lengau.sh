#!/bin/bash
# Build remaining suite tools: igbpveg, ocnbath, sibveg (after g2n/terread/casafield).
set -e

SUITE_SRC="${SUITE_SRC:-/mnt/lustre/users/msovara/SoftwareBuilds/ccam-suite}"
INSTALL_BIN="${INSTALL_BIN:-/home/apps/chpc/earth/CCAM-oneapi2021.3/bin}"
NETCDF_MODULE="${NETCDF_MODULE:-chpc/earth/netcdf/4.9.2-intel2021.3}"

ONEAPI_BASE="/home/apps/chpc/compmech/compilers/intel_2021.3/oneapi"

module purge
source "$ONEAPI_BASE/compiler/2021.3.0/env/vars.sh"
source "$ONEAPI_BASE/mpi/2021.3.0/env/vars.sh"
module load "$NETCDF_MODULE"
export PATH="${ONEAPI_BASE}/compiler/2021.3.0/linux/bin/intel64:${PATH}"

NETCDF_PREFIX=$(nc-config --prefix)
export NETCDF_ROOT="$NETCDF_PREFIX"

build_one() {
  local dir=$1 exe=$2
  [[ -d "$SUITE_SRC/$dir" ]] || { echo "SKIP $exe: no source"; return 0; }
  [[ -x "$INSTALL_BIN/$exe" ]] && { echo "SKIP $exe: installed"; return 0; }
  echo "--- Building $exe ---"
  cd "$SUITE_SRC/$dir"
  make clean 2>/dev/null || true
  # ocnbath needs netcdf_m.mod before ocnbath.f90
  if [[ -f netcdf_m.f90 ]]; then
    make FC=ifort NETCDF_ROOT="$NETCDF_PREFIX" netcdf_m.o || true
  fi
  make FC=ifort NETCDF_ROOT="$NETCDF_PREFIX" || make FC=ifort NETCDF="$NETCDF_PREFIX"
  cp -f "$exe" "$INSTALL_BIN/"
  echo "OK: $INSTALL_BIN/$exe"
}

build_one igbpveg igbpveg
build_one ocnbath ocnbath
build_one sibveg sibveg

echo ""
ls -la "$INSTALL_BIN"
