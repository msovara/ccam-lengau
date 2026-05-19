# CCAM full suite on Lengau (OneAPI)

The atmospheric model **globpea** is only one part of CCAM. A typical workflow also needs pre/post-processing and surface tools.

## Executables in the full suite

| Executable | Repository | Role |
|------------|------------|------|
| **globpea** | [ccam-ccam](https://github.com/csiro/ccam-ccam) | Main atmospheric model |
| **terread** | [ccam-terread](https://github.com/csiro/ccam-terread) | Orography / topography |
| **igbpveg** | [ccam-igbpveg](https://github.com/csiro/ccam-igbpveg) | Vegetation, soil, urban |
| **sibveg** | Bitbucket/GitHub | SIB vegetation |
| **ocnbath** | [ccam-ocnbath](https://github.com/csiro/ccam-ocnbath) | Bathymetry / rivers |
| **casafield** | [ccam-casafield](https://github.com/csiro/ccam-casafield) | Carbon cycle (CASA) |
| **aeroemiss** | [ccam-aeroemiss](https://github.com/csiro/ccam-aeroemiss) | Aerosol emissions |
| **cdfvidar** | [ccam-cdfvidar](https://github.com/csiro/ccam-cdfvidar) | Lat/lon → cubic input |
| **pcc2hist** | [ccam-pcc2hist](https://github.com/csiro/ccam-pcc2hist) | Cubic → lat/lon output |
| **g2n** | [ccam-g2n](https://github.com/csiro/ccam-g2n) | Utility |
| **smclim** | optional | May require legacy copy if not on GitHub |

Static data (vegin, ccamdata, etc.) may still live under  
`/home/apps/chpc/earth/CCAM/ccaminstall/` until you migrate those separately.

## Step 1: Download on DTN

```bash
ssh msovara@dtn.chpc.ac.za
module purge
cd /path/to/ccam-lengau   # or copy download_ccam_suite_dtn.sh to lustre
./download_ccam_suite_dtn.sh
```

Sources:

- `/mnt/lustre/users/$USER/SoftwareBuilds/ccam` — main model  
- `/mnt/lustre/users/$USER/SoftwareBuilds/ccam-suite/` — auxiliary tools  

## Step 2: Build in interactive PBS session

```bash
qsub -I -l select=1:ncpus=24:mpiprocs=24:nodetype=haswell_reg -l walltime=12:00:00 -P RCHPC -q internal -W group_list=chpc_staff -X
```

When the job starts:

```bash
cd /mnt/lustre/users/msovara/SoftwareBuilds
sed -i 's/\r$//' build_ccam_suite_lengau.sh
chmod +x build_ccam_suite_lengau.sh
./build_ccam_suite_lengau.sh
```

Install location: **`/home/apps/chpc/earth/CCAM-oneapi2021.3/bin/`**

## Step 3: Use the module

```bash
module load chpc/earth/ccam/oneapi2021.3
which globpea terread cdfvidar pcc2hist
```

## Optional: PBS batch build

```bash
qsub run_build_ccam_suite.pbs
```

Edit the PBS script for your project, queue, and paths.

## Legacy reference

The old full install is under  
`/home/apps/chpc/earth/CCAM/ccaminstall/srcNov2024/bin/`  
(Nov 2024, older compiler). The OneAPI suite replaces those binaries in  
`CCAM-oneapi2021.3/bin` when the build completes successfully.
