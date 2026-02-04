# CCAM: install under /home/apps/chpc/earth and add module

Installations go in **`/home/apps/chpc/earth/`**; module files go in **`/apps/chpc/scripts/modules/earth`** (Lengau: `chpc/earth` is a symlink to that path).

---

## 1. Install the build into /home/apps/chpc/earth

From your **built** CCAM directory (where `globpea` was created):

```bash
export CCAM_INSTALL="/home/apps/chpc/earth/CCAM-oneapi2021.3"
mkdir -p $CCAM_INSTALL/bin
cp /mnt/lustre/users/$USER/SoftwareBuilds/ccam/globpea $CCAM_INSTALL/bin/
# If you need sudo: sudo chown -R $USER:rchpc $CCAM_INSTALL
```

---

## 2. Module file

Use the file from this repo: **module/oneapi2021.3**.

**On Lengau**, copy it to the earth module tree (actual path used by the module system):

```bash
# The module system uses /cm/shared/modulefiles/chpc/earth -> /apps/chpc/scripts/modules/earth
sudo mkdir -p /apps/chpc/scripts/modules/earth/ccam
sudo cp module/oneapi2021.3 /apps/chpc/scripts/modules/earth/ccam/
sudo sed -i 's/\r$//' /apps/chpc/scripts/modules/earth/ccam/oneapi2021.3
```

If you don't have sudo, ask CHPC staff to install the module file.

**Load the module:**

```bash
module load chpc/earth/ccam/oneapi2021.3
which globpea
```

---

## 3. Verify

```bash
module purge
module load chpc/earth/ccam/oneapi2021.3
which globpea
# Run in a PBS job with mpirun, not on login node
```

---

## Summary

| Item | Value |
|------|--------|
| Install dir | `/home/apps/chpc/earth/CCAM-oneapi2021.3` |
| Executable | `$CCAM_ROOT/bin/globpea` |
| Module load | `module load chpc/earth/ccam/oneapi2021.3` |
| Module file in repo | `module/oneapi2021.3` |
