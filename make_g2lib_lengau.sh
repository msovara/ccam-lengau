#!/bin/bash
# Compile g2lib 3.1.0 in G2LIB_ROOT (sources must already be present from DTN).
set -e

G2LIB_ROOT="${G2LIB_ROOT:-/mnt/lustre/users/msovara/SoftwareBuilds/ccam-suite/src/g2nlib/g2lib-3.1.0}"
JASPER_ROOT="${JASPER_ROOT:-/mnt/lustre/users/msovara/SoftwareBuilds/ccam-suite/src/jasper/jasper-1.900.1/libjasper}"
WRF_LIB="${WRF_LIB:-/home/apps/chpc/earth/WRF-4.2.1-intel18/LIBRARIES}"

export JASPER_INC="$JASPER_ROOT/include"
export PNG_INC="$WRF_LIB/libpng-1.2.50"
export Z_INC="$WRF_LIB/zlib-1.2.12"

cd "$G2LIB_ROOT"
make -f makefile_4_wcoss \
  FC=ifort CC=icc \
  MODDIR=. \
  "LIB=./libg2_v3.1.0_4.a" \
  'FFLAGS=-O3 -traceback -module .' \
  "CFLAGS=-O3 -DLINUX -I${JASPER_INC} -I${PNG_INC} -I${Z_INC} -D__64BIT__"

# mova2i.c required when not linking libw3 (see g2lib README)
icc -c -O3 -DLINUX mova2i.c
ar ruv libg2_v3.1.0_4.a mova2i.o

ln -sfn libg2_v3.1.0_4.a libg2.a
if [[ -d include/g2_v3.1.0_4 ]]; then
  cp -f include/g2_v3.1.0_4/*.mod . 2>/dev/null || true
fi
ls -la libg2.a grib_mod.mod 2>/dev/null || ls -la libg2.a *.mod | head -5
