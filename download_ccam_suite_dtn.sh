#!/bin/bash
# Clone all CCAM suite repositories on the DTN (internet access).
# Run: module purge   (avoids git/libcurl issues with Intel libs)
#      ./download_ccam_suite_dtn.sh

set -e

SUITE_SRC="${SUITE_SRC:-/mnt/lustre/users/msovara/SoftwareBuilds/ccam-suite}"
CCAM_SRC="${CCAM_SRC:-/mnt/lustre/users/msovara/SoftwareBuilds/ccam}"

mkdir -p "$SUITE_SRC"
cd "$SUITE_SRC"

clone_github() {
  local repo=$1
  local dir=$2
  if [[ -d "$dir" ]]; then
    echo "[$dir] already exists, skipping"
    return 0
  fi
  echo "Cloning https://github.com/csiro/$repo.git -> $dir"
  git clone --depth 1 "https://github.com/csiro/${repo}.git" "$dir"
}

clone_bitbucket() {
  local repo=$1
  local dir=$2
  if [[ -d "$dir" ]]; then
    echo "[$dir] already exists, skipping"
    return 0
  fi
  echo "Cloning https://bitbucket.csiro.au/scm/CCAM/${repo}.git -> $dir"
  git clone --depth 1 "https://bitbucket.csiro.au/scm/CCAM/${repo}.git" "$dir"
}

echo "=== CCAM suite download (DTN) ==="
echo "SUITE_SRC=$SUITE_SRC"
echo "CCAM_SRC=$CCAM_SRC"
echo ""

# Auxiliary tools (GitHub)
clone_github ccam-terread    terread
clone_github ccam-cdfvidar   cdfvidar
clone_github ccam-pcc2hist   pcc2hist
clone_github ccam-aeroemiss  aeroemiss
clone_github ccam-igbpveg    igbpveg
clone_github ccam-ocnbath    ocnbath
clone_github ccam-casafield  casafield
clone_github ccam-g2n        g2n

# sibveg: try GitHub then Bitbucket
if [[ ! -d sibveg ]]; then
  if ! git clone --depth 1 https://github.com/csiro/ccam-sibveg.git sibveg 2>/dev/null; then
    clone_bitbucket sibveg sibveg
  fi
fi

# smclim (optional; may not be on public GitHub)
if [[ ! -d smclim ]]; then
  git clone --depth 1 https://github.com/csiro/ccam-smclim.git smclim 2>/dev/null || \
  git clone --depth 1 https://bitbucket.csiro.au/scm/CCAM/smclim.git smclim 2>/dev/null || \
  echo "[smclim] not cloned (optional; copy from legacy ccaminstall if needed)"
fi

# Main model (atmospheric core)
if [[ ! -d "$CCAM_SRC/.git" ]]; then
  echo "Cloning main model -> $CCAM_SRC"
  git clone --depth 1 https://github.com/csiro/ccam-ccam.git "$CCAM_SRC"
else
  echo "[ccam] $CCAM_SRC already exists"
fi

echo ""
echo "=== Download finished ==="
ls -la "$SUITE_SRC"
echo ""
echo "Next: interactive PBS session, then run build_ccam_suite_lengau.sh"
