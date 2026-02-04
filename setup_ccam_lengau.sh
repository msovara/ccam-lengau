#!/bin/bash
# Clone CCAM from CSIRO Bitbucket then build on Lengau with Intel OneAPI.
# Run on DTN for clone (module purge first), then build in interactive PBS session.
# Edit variables below if your paths differ.

set -e

CCAM_SRC="${CCAM_SRC:-/mnt/lustre/users/$USER/SoftwareBuilds/ccam}"
CCAM_REPO="${CCAM_REPO:-https://github.com/csiro/ccam-ccam.git}"

echo "CCAM_SRC=$CCAM_SRC"
echo ""

# --- Clone (do on DTN with module purge to avoid git/libcurl issues) ---
mkdir -p "$CCAM_SRC"
cd "$CCAM_SRC"

if [[ ! -d ccam ]]; then
  echo "Cloning CCAM from $CCAM_REPO ..."
  git clone "$CCAM_REPO" ccam
else
  echo "ccam/ already exists; pulling latest."
  cd ccam
  git pull || true
  cd "$CCAM_SRC"
fi

echo ""
echo "Clone done. To build: start an interactive PBS session and run build_ccam_lengau.sh from this repo."
echo "  qsub -I -l select=1:ncpus=24:mpiprocs=24:nodetype=haswell_reg -l walltime=12:00:00 -P RCHPC -q internal -W group_list=chpc_staff -X"
echo "  cd $CCAM_SRC && ./build_ccam_lengau.sh"
