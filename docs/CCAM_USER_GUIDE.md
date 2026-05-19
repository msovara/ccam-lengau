# CCAM on Lengau — user guide

This guide is for **researchers running CCAM** on CHPC Lengau. It covers the module, installed tools, static input data, and what you must provide yourself.

## Quick start

```bash
module load chpc/earth/ccam/oneapi2021.3

# Check tools and paths
echo "CCAM_ROOT=$CCAM_ROOT"
echo "CCAM_DATA=$CCAM_DATA"
which globpea g2n terread igbpveg

# Run the model inside a PBS job (not on the login node)
mpirun -np 24 globpea <your run options>
```

| Item | Location |
|------|----------|
| **Executables** | `$CCAM_ROOT/bin/` → `/home/apps/chpc/earth/CCAM-oneapi2021.3/bin/` |
| **Shared static data** | `$CCAM_DATA` → `/home/apps/chpc/earth/CCAM/ccaminstall/` |
| **Vegetation inputs** | `$VEGIN` → `$CCAM_DATA/vegin` (~20 GB) |
| **Auxiliary datasets** | `$CCAM_DATA/ccamdata` (~100 MB) |

## What is installed (OneAPI build)

After `module load chpc/earth/ccam/oneapi2021.3`, these **executables** are on your `PATH`:

| Tool | Purpose |
|------|---------|
| **globpea** | Main CCAM atmospheric model (MPI — use `mpirun`) |
| **terread** | Orography / topography processing |
| **igbpveg** | IGBP vegetation, soil, urban fields |
| **sibveg** | SIB vegetation |
| **ocnbath** | Ocean bathymetry / rivers |
| **casafield** | CASA carbon-cycle fields |
| **aeroemiss** | Aerosol emissions |
| **cdfvidar** | Lat/lon → cubic grid |
| **pcc2hist** | Cubic → lat/lon history (MPI) |
| **g2n** | GRIB → NetCDF (initial conditions) |

**Not in the OneAPI install (optional / legacy only):**

| Tool | Notes |
|------|--------|
| **smclim** | Soil-climate utility; source is not on public GitHub. Legacy binary: `/home/apps/chpc/earth/CCAM/ccaminstall/srcNov2024/bin/smclim` (older Intel 2016 stack — do not mix with OneAPI runs without rebuilding). |
| **ccam2tapmx, one, qsplice, vpr** | Present in old `srcNov2024/bin` only; not part of this OneAPI suite build. |

Verify what is available:

```bash
module load chpc/earth/ccam/oneapi2021.3
ls -la $CCAM_ROOT/bin/
```

## Static data: CHPC vs user (important)

**Static files are not compiled** and are **not copied** into `CCAM-oneapi2021.3` (the vegetation archive alone is ~20 GB).

| Data | Typical size | Who provides it |
|------|--------------|-----------------|
| **vegin/** | ~20 GB | **CHPC / earth group** — shared under `ccaminstall` (read-only for users) |
| **ccamdata/** | ~100 MB | **CHPC** — radiation/auxiliary data under `ccaminstall` |
| **cnsdir/, stdata/, gcmsst/** | varies | Often empty until populated; see CSIRO download scripts if needed |

**Users** only need to:

1. Point namelists and run scripts at `$CCAM_DATA`, `$VEGIN`, or subpaths (not hard-coded personal copies unless your experiment requires it).
2. Download or add **extra** datasets for special experiments (custom vegetation, private projects).
3. Use CSIRO/CHPC download scripts if a shared directory is incomplete — scripts live in:
   `/home/apps/chpc/earth/CCAM/ccaminstall/CCAM_Download_scripts/`
   (`download_vegin.sh`, `download_ccamdata.sh`, etc.)

**Do not** expect `build_ccam_suite_lengau.sh` to download or install vegin; that is **data provisioning**, separate from the compiler build.

## Environment variables (set by the module)

| Variable | Meaning |
|----------|---------|
| `CCAM_ROOT` | OneAPI install root (binaries) |
| `CCAM_DATA` | Shared static data root (`ccaminstall`) |
| `VEGIN` | Vegetation data directory |

Your run scripts and namelists should use these variables where possible so jobs stay portable across users.

## Running globpea

1. **Always use a PBS job** for compilation and for `globpea` / `mpirun` (login-node runs may be killed).
2. Load the module and NetCDF (the module loads `chpc/earth/netcdf/4.9.2-intel2021.3` automatically).
3. Example interactive allocation:

```bash
qsub -I -l select=1:ncpus=24:mpiprocs=24:nodetype=haswell_reg \
  -l walltime=12:00:00 -P <PROJECT> -q <QUEUE> -W group_list=<GROUP> -X
```

```bash
module load chpc/earth/ccam/oneapi2021.3
cd $PBS_O_WORKDIR
mpirun -np 24 globpea
```

## Typical workflow (tools + data)

```text
  GRIB analyses  --g2n-->  NetCDF ICs
  Topography     --terread-->  orography files
  Surface        --igbpveg / sibveg / ocnbath-->  surface fields
  Model          --globpea (mpirun)-->  cubic output
  Post           --pcc2hist / cdfvidar-->  lat/lon products
```

Static data under `$CCAM_DATA` is read according to your namelist and CSIRO documentation — see [CSIRO CCAM](https://research.csiro.au/ccam/).

## Toolchain (for reference)

| Component | Version / module |
|-----------|------------------|
| Compiler + MPI | Intel OneAPI 2021.3 (`/home/apps/chpc/compmech/compilers/intel_2021.3/oneapi`) |
| NetCDF | `chpc/earth/netcdf/4.9.2-intel2021.3` |
| Source (public) | [github.com/csiro/ccam-ccam](https://github.com/csiro/ccam-ccam) and related `ccam-*` repos |

## Legacy install (do not mix casually)

| | Legacy | OneAPI (use this) |
|---|--------|-------------------|
| Binaries | `/home/apps/chpc/earth/CCAM/ccaminstall/srcNov2024/bin/` | `$CCAM_ROOT/bin/` |
| Data | `/home/apps/chpc/earth/CCAM/ccaminstall/` | Same — `$CCAM_DATA` |
| Compiler | Intel 2016 / old NetCDF | OneAPI 2021.3 |

Use **OneAPI binaries** with **shared ccaminstall data**. Avoid calling legacy `smclim` or old `globpea` in the same workflow as OneAPI tools unless you know they are compatible.

## Building from source (maintainers)

See [CCAM_FULL_SUITE.md](CCAM_FULL_SUITE.md), [CCAM_DOWNLOAD_AND_BUILD.md](CCAM_DOWNLOAD_AND_BUILD.md), and [CCAM_INSTALL_AND_MODULE.md](CCAM_INSTALL_AND_MODULE.md).

## Support

- **Module / install issues:** CHPC earth / RCHPC support, or the maintainer of `ccam-lengau` on GitHub.
- **Science / namelists:** CSIRO CCAM documentation and your project PI.
