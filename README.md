# CCAM on CHPC Lengau

Build and module setup for the **Conformal Cubic Atmospheric Model (CCAM)** on the CHPC Lengau cluster, using **Intel OneAPI** (no license required).

## Quick start (use pre-installed module)

On Lengau:

```bash
module load chpc/earth/ccam/oneapi2021.3
# In a PBS job:
mpirun -np 24 globpea <your options>
```

- **Installation:** `/home/apps/chpc/earth/CCAM-oneapi2021.3/bin/`
- **Main executable:** `globpea`
- **Full suite:** terread, igbpveg, cdfvidar, pcc2hist, aeroemiss, ocnbath, casafield, g2n, sibveg, … (see [CCAM_FULL_SUITE.md](docs/CCAM_FULL_SUITE.md))

**Note:** If only `globpea` is present, build the full suite with `build_ccam_suite_lengau.sh` (after `download_ccam_suite_dtn.sh` on the DTN).

## Contents of this repo

| Item | Description |
|------|-------------|
| **build_ccam_lengau.sh** | Build **globpea** only (OneAPI). Interactive PBS session. |
| **build_ccam_suite_lengau.sh** | Build **full suite** (all tools). Interactive PBS or `run_build_ccam_suite.pbs`. |
| **download_ccam_suite_dtn.sh** | Clone all repos on DTN (`module purge` first). |
| **setup_ccam_lengau.sh** | Optional: clone main CCAM only. |
| **module/oneapi2021.3** | Environment-modules file for `chpc/earth/ccam/oneapi2021.3`. |
| **docs/** | Guides including [CCAM_FULL_SUITE.md](docs/CCAM_FULL_SUITE.md). |

## Building from source (Lengau)

1. **Clone CCAM** on the DTN node (has internet):  
   See [CCAM_DOWNLOAD_AND_BUILD.md](docs/CCAM_DOWNLOAD_AND_BUILD.md) or run `setup_ccam_lengau.sh` (with `module purge` first on DTN).

2. **Get an interactive session** and build:
   ```bash
   qsub -I -l select=1:ncpus=24:mpiprocs=24:nodetype=haswell_reg -l walltime=12:00:00 -P RCHPC -q internal -W group_list=chpc_staff -X
   ```
   When the job starts:
   ```bash
   cd /mnt/lustre/users/$USER/SoftwareBuilds/ccam
   ./build_ccam_lengau.sh
   ```

3. **Install and module:**  
   See [CCAM_INSTALL_AND_MODULE.md](docs/CCAM_INSTALL_AND_MODULE.md).

## Toolchain

- **Compiler & MPI:** Intel OneAPI 2021.3 (`/home/apps/chpc/compmech/compilers/intel_2021.3/oneapi`)
- **NetCDF:** `chpc/earth/netcdf/4.9.2-intel2021.3`
- **Source:** [CCAM on GitHub (CSIRO)](https://github.com/csiro/ccam-ccam) — clone from here for the latest release.

## Documentation

- [CCAM_DOWNLOAD_AND_BUILD.md](docs/CCAM_DOWNLOAD_AND_BUILD.md) – Download and build (OneAPI, optional licensed Intel)
- [RUN_CCAM_BUILD_IN_TERMINAL.md](docs/RUN_CCAM_BUILD_IN_TERMINAL.md) – Copy-paste commands for your terminal
- [CCAM_INSTALL_AND_MODULE.md](docs/CCAM_INSTALL_AND_MODULE.md) – Install under `/home/apps/chpc/earth` and add the module file
- [CCAM_LENGAU_BUILD_NOTES.md](docs/CCAM_LENGAU_BUILD_NOTES.md) – GCC vs OneAPI, libmvec, license notes

## License and attribution

- **CCAM** is developed by CSIRO. See [CSIRO CCAM](https://research.csiro.au/ccam/) and the license in the CCAM source.
- This repository only contains build/install scripts and module files for CHPC Lengau.
