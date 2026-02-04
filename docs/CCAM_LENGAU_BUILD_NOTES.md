# CCAM build on Lengau – compiler / libmvec issue

## Summary

**Problem:** The `ld: cannot find -lmvec` error when building CCAM with GCC on Lengau comes from mixing multiple GCC versions (system, NetCDF, loaded modules). The linker can't find a consistent `libmvec`.

**Recommendation:** Build CCAM with **Intel OneAPI** (no license required on Lengau). This repo uses OneAPI 2021.3 under `chpc/compmech`.

---

## If you still need a GCC build later

- Use a **single GCC** for the whole stack (compiler + NetCDF built with same GCC).
- Or try building without flags that pull in `-lmvec` (may reduce performance).

See the main [CCAM_DOWNLOAD_AND_BUILD.md](CCAM_DOWNLOAD_AND_BUILD.md) for the OneAPI build procedure.
