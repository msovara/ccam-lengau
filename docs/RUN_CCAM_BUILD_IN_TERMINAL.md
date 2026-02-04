# Run CCAM build in your terminal (Lengau)

Use this in **your own terminal**. Copy each block when you're ready.

**Default:** The build script uses **Intel OneAPI** (under `chpc/compmech`). OneAPI does **not** require an Intel license.

---

## 1. SSH to Lengau

```bash
ssh msovara@lengau.chpc.ac.za
```

---

## 2. Start an interactive PBS session (12 h, 24 cores)

```bash
qsub -I -l select=1:ncpus=24:mpiprocs=24:nodetype=haswell_reg -l walltime=12:00:00 -P RCHPC -q internal -W group_list=chpc_staff -X
```

Wait until you get a shell prompt on a compute node.

---

## 3. Run the build script

Copy **build_ccam_lengau.sh** from this repo to Lengau (e.g. `/mnt/lustre/users/msovara/SoftwareBuilds/ccam/`), then:

```bash
cd /mnt/lustre/users/msovara/SoftwareBuilds/ccam
sed -i 's/\r$//' build_ccam_lengau.sh   # fix line endings if copied from Windows
chmod +x build_ccam_lengau.sh
./build_ccam_lengau.sh
```

---

## 4. Install and module

After a successful build, see [CCAM_INSTALL_AND_MODULE.md](CCAM_INSTALL_AND_MODULE.md). The module file is in this repo at **module/oneapi2021.3**.

---

## Toolchain (OneAPI – no license)

| Component | How it's set |
|-----------|----------------|
| Compiler | OneAPI 2021.3 – `source .../oneapi/compiler/2021.3.0/env/vars.sh` |
| MPI | OneAPI MPI 2021.3 – `source .../oneapi/mpi/2021.3.0/env/vars.sh` |
| NetCDF | `chpc/earth/netcdf/4.9.2-intel2021.3` |
| CCAM source | `/mnt/lustre/users/$USER/SoftwareBuilds/ccam` |
