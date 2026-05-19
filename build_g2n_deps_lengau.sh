#!/bin/bash
# Build Jasper + NCEP g2lib for ccam-g2n (paths expected by g2n/makefile).
# Run inside PBS (same OneAPI + NetCDF env as build_ccam_suite_lengau.sh).
#
# Layout created under $SUITE_SRC/src/:
#   jasper/jasper-1.900.1/libjasper/{libjasper.a,include/jasper,lib/*.a}
#   g2nlib/g2lib-3.1.0/{libg2.a,*.mod,...}

set -e

SUITE_SRC="${SUITE_SRC:-/mnt/lustre/users/msovara/SoftwareBuilds/ccam-suite}"
DEPS_SRC="${DEPS_SRC:-$SUITE_SRC/src}"
JASPER_TOP="$DEPS_SRC/jasper/jasper-1.900.1"
JASPER_ROOT="$JASPER_TOP/libjasper"
G2LIB_ROOT="$DEPS_SRC/g2nlib/g2lib-3.1.0"

WRF_LIB="${WRF_LIB:-/home/apps/chpc/earth/WRF-4.2.1-intel18/LIBRARIES}"
WRF_JASPER="$WRF_LIB/jasper-1.900.1"
WRF_PNG="$WRF_LIB/libpng-1.2.50"
WRF_ZLIB="$WRF_LIB/zlib-1.2.12"

G2_TAG="${G2_TAG:-g2_v3.1.0}"

echo "=== g2n dependencies (Jasper + g2lib) ==="
echo "DEPS_SRC=$DEPS_SRC"
echo "JASPER_ROOT=$JASPER_ROOT"
echo "G2LIB_ROOT=$G2LIB_ROOT"
echo ""

mkdir -p "$DEPS_SRC/jasper" "$DEPS_SRC/g2nlib"

# --- Jasper (reuse WRF-built 1.900.1; g2n links with -L libjasper -ljasper) ---
if [[ -f "$JASPER_ROOT/libjasper.a" ]]; then
  echo "Jasper OK: $JASPER_ROOT/libjasper.a"
else
  echo "--- Jasper 1.900.1 layout from $WRF_JASPER ---"
  [[ -d "$WRF_JASPER/src/libjasper/.libs" ]] || {
    echo "FAIL: WRF jasper not found at $WRF_JASPER"
    exit 1
  }
  mkdir -p "$JASPER_TOP"
  if [[ ! -e "$JASPER_TOP/src" ]]; then
    ln -sfn "$WRF_JASPER" "$JASPER_TOP/wrf-jasper-src"
  fi
  mkdir -p "$JASPER_ROOT/lib" "$JASPER_ROOT/include"
  ln -sfn "$WRF_JASPER/src/libjasper/.libs/libjasper.a" "$JASPER_ROOT/libjasper.a"
  ln -sfn "$WRF_JASPER/src/libjasper/.libs/libjasper.a" "$JASPER_ROOT/lib/libjasper.a"
  ln -sfn "$WRF_JASPER/src/libjasper/include/jasper" "$JASPER_ROOT/include/jasper"
  ln -sfn "$WRF_PNG/.libs/libpng12.a" "$JASPER_ROOT/lib/libpng12.a"
  ln -sfn "$WRF_PNG/.libs/libpng.a" "$JASPER_ROOT/lib/libpng.a"
  ln -sfn "$WRF_PNG/.libs/libpng12.a" "$JASPER_ROOT/libpng.a"
  ln -sfn "$WRF_ZLIB/libz.a" "$JASPER_ROOT/lib/libz.a"
  echo "OK: Jasper at $JASPER_ROOT"
fi

# --- NCEP g2lib 3.1.0 ---
if [[ -f "$G2LIB_ROOT/libg2.a" ]]; then
  echo "g2lib OK: $G2LIB_ROOT/libg2.a"
else
  echo "--- NCEP g2lib $G2_TAG ---"
  mkdir -p "$G2LIB_ROOT"
  if [[ ! -f "$G2LIB_ROOT/gribmod.f" ]]; then
    G2_CLONE="$DEPS_SRC/g2nlib/NCEPLIBS-g2"
    if [[ -f "$G2_CLONE/src/gribmod.f" ]]; then
      cp -a "$G2_CLONE/src/." "$G2LIB_ROOT/"
    else
      echo "FAIL: g2 sources missing. On DTN run:"
      echo "  git clone --depth 1 --branch $G2_TAG https://github.com/NOAA-EMC/NCEPLIBS-g2.git $G2_CLONE"
      echo "  cp -a $G2_CLONE/src/. $G2LIB_ROOT/"
      exit 1
    fi
  fi

  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  export G2LIB_ROOT JASPER_ROOT WRF_LIB
  "$script_dir/make_g2lib_lengau.sh"

  [[ -f "$G2LIB_ROOT/libg2.a" ]] && [[ -f "$G2LIB_ROOT/grib_mod.mod" || -f "$G2LIB_ROOT/GRIB_MOD.mod" ]] || {
    echo "FAIL: g2lib build missing libg2.a or grib_mod.mod in $G2LIB_ROOT"
    ls -la "$G2LIB_ROOT" | head -20
    exit 1
  }
  echo "OK: g2lib at $G2LIB_ROOT"
fi

echo ""
echo "=== g2n dependencies ready ==="
ls -la "$JASPER_ROOT/libjasper.a" "$G2LIB_ROOT/libg2.a"
