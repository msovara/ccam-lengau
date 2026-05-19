# CCAM on CHPC Lengau

Build scripts and user documentation for the **Conformal Cubic Atmospheric Model (CCAM)** on the CHPC Lengau cluster, using **Intel OneAPI 2021.3** (no separate Intel license required for this toolchain).

**Repository:** [github.com/msovara/ccam-lengau](https://github.com/msovara/ccam-lengau)

---

## For users (running CCAM)

```bash
module load chpc/earth/ccam/oneapi2021.3
which globpea
echo $CCAM_ROOT $CCAM_DATA $VEGIN
```

| What | Where |
|------|--------|
| **Executables** | `/home/apps/chpc/earth/CCAM-oneapi2021.3/bin/` |
| **Static data (vegin, ccamdata)** | `/home/apps/chpc/earth/CCAM/ccaminstall/` via `$CCAM_DATA` |

**Read first:** [docs/CCAM_USER_GUIDE.md](docs/CCAM_USER_GUIDE.md) — module usage, full tool list, static data policy (CHPC vs user), PBS notes, legacy vs OneAPI.

**Installed tools (OneAPI):** `globpea`, `terread`, `igbpveg`, `sibveg`, `ocnbath`, `casafield`, `aeroemiss`, `cdfvidar`, `pcc2hist`, `g2n`.

**Static data** (~20 GB vegin + ccamdata) is **shared CHPC data**, not part of the compile. Users reference `$CCAM_DATA` / `$VEGIN`; they do not need to copy vegin into their home directory unless their experiment requires it.

**smclim** is not in the public suite build; see the user guide for the legacy binary path if needed.

Run **globpea** only inside **PBS jobs** with `mpirun`, not on the login node.

---

## For maintainers (building / updating the install)

| Script | Purpose |
|--------|---------|
| `download_ccam_suite_dtn.sh` | Clone sources on DTN (`module purge` first) |
| `build_ccam_lengau.sh` | Build **globpea** only (interactive PBS) |
| `build_ccam_suite_lengau.sh` | Build full suite (+ `build_g2n_deps_lengau.sh` for g2n) |
| `build_g2n_deps_lengau.sh` | Jasper + NCEP g2lib for **g2n** |
| `run_build_ccam_suite.pbs` | PBS batch full suite |
| `module/oneapi2021.3` | Environment module → install under `/apps/chpc/scripts/modules/earth/ccam/` |

**Install layout**

```text
/home/apps/chpc/earth/CCAM-oneapi2021.3/     # CCAM_ROOT — binaries only
/home/apps/chpc/earth/CCAM/ccaminstall/     # CCAM_DATA — shared static data (vegin, ccamdata, …)
```

**Toolchain:** OneAPI 2021.3 + `chpc/earth/netcdf/4.9.2-intel2021.3`  
**Model source:** [csiro/ccam-ccam](https://github.com/csiro/ccam-ccam) and related `ccam-*` repos on GitHub.

---

## Documentation

| Document | Audience |
|----------|----------|
| [CCAM_USER_GUIDE.md](docs/CCAM_USER_GUIDE.md) | **End users** — module, data, workflows |
| [CCAM_FULL_SUITE.md](docs/CCAM_FULL_SUITE.md) | Full suite build steps |
| [CCAM_DOWNLOAD_AND_BUILD.md](docs/CCAM_DOWNLOAD_AND_BUILD.md) | Download and build |
| [CCAM_INSTALL_AND_MODULE.md](docs/CCAM_INSTALL_AND_MODULE.md) | Install path and module file |
| [CCAM_LENGAU_BUILD_NOTES.md](docs/CCAM_LENGAU_BUILD_NOTES.md) | GCC vs OneAPI, licenses |
| [RUN_CCAM_BUILD_IN_TERMINAL.md](docs/RUN_CCAM_BUILD_IN_TERMINAL.md) | Copy-paste commands |

---

## License and attribution

CCAM is developed by **CSIRO**. See [CSIRO CCAM](https://research.csiro.au/ccam/) and the license in the source repositories.

This repository contains CHPC Lengau **build/install scripts and documentation** only, not the model source code.
