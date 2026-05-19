# CCAM full suite on Lengau (OneAPI)

The atmospheric model **globpea** is only one part of CCAM. Pre/post-processing and surface tools are separate executables, built from separate CSIRO repositories.

**Users:** see [CCAM_USER_GUIDE.md](CCAM_USER_GUIDE.md) for `module load`, static data, and run workflows.

---

## Executables

| Executable | Repository | Role | Build |
|------------|------------|------|--------|
| **globpea** | [ccam-ccam](https://github.com/csiro/ccam-ccam) | Main model | MPI (`mpiifort`) |
| **pcc2hist** | [ccam-pcc2hist](https://github.com/csiro/ccam-pcc2hist) | Cubic → lat/lon | MPI |
| **aeroemiss** | [ccam-aeroemiss](https://github.com/csiro/ccam-aeroemiss) | Aerosol emissions | serial |
| **cdfvidar** | [ccam-cdfvidar](https://github.com/csiro/ccam-cdfvidar) | Lat/lon → cubic | serial |
| **g2n** | [ccam-g2n](https://github.com/csiro/ccam-g2n) | GRIB → NetCDF | serial + **g2lib/Jasper** |
| **terread** | [ccam-terread](https://github.com/csiro/ccam-terread) | Orography | serial |
| **igbpveg** | [ccam-igbpveg](https://github.com/csiro/ccam-igbpveg) | Vegetation / soil | serial |
| **sibveg** | Bitbucket / GitHub | SIB vegetation | serial |
| **ocnbath** | [ccam-ocnbath](https://github.com/csiro/ccam-ocnbath) | Bathymetry | serial |
| **casafield** | [ccam-casafield](https://github.com/csiro/ccam-casafield) | CASA fields | serial |
| **smclim** | Bitbucket (restricted) | Soil climate | serial — **not in public build** |

**Install:** `/home/apps/chpc/earth/CCAM-oneapi2021.3/bin/`

---

## Static data (not part of the build)

Large input datasets stay under **shared CHPC storage**, not in `CCAM-oneapi2021.3`:

| Path | Size (approx.) | Module variable |
|------|----------------|-----------------|
| `.../ccaminstall/vegin` | ~20 GB | `$VEGIN` |
| `.../ccaminstall/ccamdata` | ~100 MB | `$CCAM_DATA/ccamdata` |

The module sets `CCAM_DATA=/home/apps/chpc/earth/CCAM/ccaminstall`.  
Download scripts: `ccaminstall/CCAM_Download_scripts/`.

---

## g2n dependencies

**g2n** requires NCEP **g2lib** 3.1.0 and **Jasper** 1.900.1. The build script `build_g2n_deps_lengau.sh`:

1. Stages Jasper from the WRF tree (`WRF-4.2.1-intel18/LIBRARIES/jasper-1.900.1`).
2. Builds g2lib from NOAA [NCEPLIBS-g2](https://github.com/NOAA-EMC/NCEPLIBS-g2) tag `g2_v3.1.0` (sources cloned on **DTN** into `ccam-suite/src/g2nlib/`).
3. Compiles `mova2i.c` into the library (required when not linking libw3).

Layout expected by `g2n/makefile`:

```text
ccam-suite/src/jasper/jasper-1.900.1/libjasper/
ccam-suite/src/g2nlib/g2lib-3.1.0/
```

---

## Step 1: Download on DTN

```bash
ssh <user>@dtn.chpc.ac.za
module purge
cd /path/to/ccam-lengau
export SUITE_SRC=/mnt/lustre/users/$USER/SoftwareBuilds/ccam-suite
export CCAM_SRC=/mnt/lustre/users/$USER/SoftwareBuilds/ccam
./download_ccam_suite_dtn.sh
```

This also clones **NCEPLIBS-g2** (`g2_v3.1.0`) for g2n.

---

## Step 2: Build (PBS — not login node)

Interactive:

```bash
qsub -I -l select=1:ncpus=24:mpiprocs=24:nodetype=haswell_reg \
  -l walltime=12:00:00 -P RCHPC -q internal -W group_list=chpc_staff -X
```

```bash
cd /mnt/lustre/users/$USER/SoftwareBuilds
sed -i 's/\r$//' *.sh
chmod +x build_ccam_suite_lengau.sh build_g2n_deps_lengau.sh
./build_ccam_suite_lengau.sh
```

Or batch: `qsub run_build_ccam_suite.pbs`

**Resume** after partial success: `build_ccam_suite_resume_lengau.sh` (from g2n onward).

---

## Step 3: Module for users

```bash
module load chpc/earth/ccam/oneapi2021.3
which globpea g2n terread
```

Module file in repo: `module/oneapi2021.3` →  
`/apps/chpc/scripts/modules/earth/ccam/oneapi2021.3`

---

## Legacy reference

Old binaries (Nov 2024, Intel 2016):  
`/home/apps/chpc/earth/CCAM/ccaminstall/srcNov2024/bin/`

Includes **smclim**, **ccam2tapmx**, **one**, **qsplice**, **vpr** not rebuilt with OneAPI.  
**Data** under `ccaminstall/` is still used via `$CCAM_DATA` for the OneAPI install.
