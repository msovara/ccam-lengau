# Download and build CCAM on Lengau (Intel OneAPI)

This guide covers downloading the latest CCAM source from CSIRO and building it on CHPC Lengau with **Intel OneAPI** (recommended; avoids the GCC/libmvec issues).

---

## 1. Where CCAM lives

- **Main repo (atmospheric model):** [CCAM on CSIRO Bitbucket](https://bitbucket.csiro.au/projects/CCAM/repos/ccam/browse)
- **Docs:** [CSIRO CCAM](https://research.csiro.au/ccam/)
- **Requirements:** Fortran compiler (Intel recommended), MPI, NetCDF.

---

## 2. Clone the latest CCAM code

**On Lengau** (use a login node or a node with git and network access):

```bash
# Choose a directory for sources (e.g. under your home or lustre)
export CCAM_SRC=/mnt/lustre/users/$USER/ccam-src
mkdir -p $CCAM_SRC
cd $CCAM_SRC
```

**Clone the main CCAM repository (GLOBPEA – atmospheric model):**

```bash
# Main model (public repo)
git clone https://bitbucket.csiro.au/scm/CCAM/ccam.git
cd ccam
git pull origin master   # or main, depending on default branch
```

If the project key is lowercase on your Bitbucket:

```bash
git clone https://bitbucket.csiro.au/scm/ccam/ccam.git
```

**Optional – related CSIRO repos** (only if you need these tools):

```bash
cd $CCAM_SRC
git clone https://bitbucket.csiro.au/scm/CCAM/terread.git
git clone https://bitbucket.csiro.au/scm/CCAM/igbpveg.git
git clone https://bitbucket.csiro.au/scm/CCAM/sibveg.git
git clone https://bitbucket.csiro.au/scm/CCAM/ocnbath.git
git clone https://bitbucket.csiro.au/scm/CCAM/casafield.git
git clone https://bitbucket.csiro.au/scm/CCAM/cdfvidar.git
git clone https://bitbucket.csiro.au/scm/CCAM/aeroemiss.git
git clone https://bitbucket.csiro.au/scm/CCAM/pcc2hist.git
git clone https://bitbucket.csiro.au/scm/CCAM/scripts.git
```

Use the same pattern (CCAM vs ccam) as for the main `ccam` clone if one fails.

---

## 3. Load environment on Lengau (Intel OneAPI + NetCDF + MPI)

Use **one** consistent Intel toolchain. Do **not** mix with GCC.

**Recommended: Intel OneAPI (no license)** – Lengau has license issues with licensed Intel compilers. Use the OneAPI installation under `chpc/compmech`:

```bash
module purge
source /home/apps/chpc/compmech/compilers/intel_2021.3/oneapi/compiler/2021.3.0/env/vars.sh
source /home/apps/chpc/compmech/compilers/intel_2021.3/oneapi/mpi/2021.3.0/env/vars.sh
module load chpc/earth/netcdf/4.9.2-intel2021.3
export MPIF90=mpiifort
```

**Alternative: licensed Intel** (only if license is available):

```bash
module purge
module load chpc/parallel_studio_xe/2020u1
module load chpc/compmech/openmpi/5.0.7-intel2020u1
module load chpc/earth/netcdf/4.7.4/intel2020u1
```

Verify:

```bash
which ifort mpif90 nc-config
ifort --version
mpif90 --version
nc-config --prefix
```

---

## 3b. Interactive session for the build (Lengau)

Builds are best done in an **interactive PBS session** so you have a compute node with compilers and enough time. Request one with:

```bash
qsub -I -l select=1:ncpus=24:mpiprocs=24:nodetype=haswell_reg -l walltime=12:00:00 -P RCHPC -q internal -W group_list=chpc_staff -X
```

When the job starts, you get a shell on a haswell node; then load the Intel/NetCDF/MPI modules (Step 3) and run the build (Step 4) in that session.

---

## 4. Build CCAM (Intel is the default)

CCAM's default `make` target is for **Intel Fortran**. Do **not** use `GFORTRAN=yes` (that's for GCC and can bring back libmvec issues).

Use the **build_ccam_lengau.sh** script from this repo (recommended), or by hand:

```bash
cd $CCAM_SRC/ccam
export NETCDF_ROOT=$(nc-config --prefix)
make clean
make FC=mpiifort NETCDF_ROOT=$NETCDF_ROOT
```

After a successful build, the executable is `globpea` in the same directory.

---

## 5. Troubleshooting

| Issue | What to do |
|-------|------------|
| `cannot find -lmvec` | You're still using or linking to GCC. Use only Intel modules and do not load gcc; build with OneAPI (see [CCAM_LENGAU_BUILD_NOTES.md](CCAM_LENGAU_BUILD_NOTES.md)). |
| NetCDF not found | Set `NETCDF_ROOT=$(nc-config --prefix)` and pass to `make`; ensure the netcdf module is built with the same compiler (Intel). |
| MPI not found | Use OneAPI MPI (source vars.sh) and pass `FC=mpiifort` to make. |
| Clone asks for password | Use HTTPS with a Bitbucket app password, or SSH if you have keys. |
| Repo not found / 404 | Try the other project name: `CCAM` vs `ccam` in the clone URL. |

---

## 6. References

- [CSIRO CCAM – Installing CCAM](https://research.csiro.au/ccam/getting-started/instructions-for-installing-ccam/)
- [CCAM software and model configuration](https://research.csiro.au/ccam/software-and-model-configuration/)
- [CHPC compilers (Lengau)](https://wiki.chpc.ac.za/howto:compilers)
- [CCAM_LENGAU_BUILD_NOTES.md](CCAM_LENGAU_BUILD_NOTES.md) (GCC vs OneAPI and libmvec)
