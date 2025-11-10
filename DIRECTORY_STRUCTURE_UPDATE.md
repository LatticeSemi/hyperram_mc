# Directory Structure Update Summary

**Date:** November 10, 2025

## Changes Made

### Old Structure (Removed)
- ❌ `soc/` - Integration examples
- ❌ `eval/` - Evaluation files

### New Structure (Added)
- ✅ `example_design/` - Radiant/Propel project examples
- ✅ `testbench/` - Testbench files
- ✅ `sim/` - Simulation scripts, memory init files, prebuilt libraries (pmi, lfmxo5, etc.)

---

## Updated Files

### 1. **README.md**
**Changes:**
- Updated directory structure diagram to show new layout
- Added descriptions for `example_design/`, `testbench/`, and `sim/`

**New Directory Structure:**
```
hyperram_mc/
├── rtl/                   # RTL source files
├── doc/                   # Documentation (introduction.html)
├── plugin/                # Tool plugins
├── testbench/             # Testbench files
├── sim/                   # Simulation scripts, memory init files, prebuilt libraries
├── example_design/        # Example Radiant/Propel projects
├── metadata.xml           # IP metadata (includes version)
├── bus_interface.xml      # Bus interface definitions
├── memory_map.xml         # Memory map definitions
└── README.md              # This file
```

---

### 2. **scripts/README.md**
**Changes:**
- Updated "What Gets Released" section to include new directories
- Added documentation for automatic cleanup of simulation artifacts
- Removed reference to `soc/` directory

**What Gets Released (Updated):**
```
release/vX.Y.Z.## branch contains:
├── rtl/                 # All RTL files
├── doc/                 # Documentation
├── plugin/              # Plugin scripts
├── testbench/           # Testbench files
├── sim/                 # Simulation scripts, memory init files, prebuilt libraries
├── example_design/      # Example Radiant/Propel projects
├── metadata.xml         # IP metadata (includes version)
├── bus_interface.xml    # Bus interface definitions
├── memory_map.xml       # Memory map definitions
├── README.md            # Project README
├── QUICKSTART.md        # Quick start guide (when created)
└── LICENSE              # License file
```

**Excluded from git via .gitignore:**
- Simulation artifacts (`*.wlf`, `*.log`, `transcript`)
- Compiled working directory (`work/`)
- These files are never committed to git and won't appear in releases

**Committed to git and included in releases:**
- ✅ `bht_ini.bin` - Required by cpu0.v during simulation
- ✅ Prebuilt libraries in `sim/lfmxo5/`, `sim/pmi/`, `sim/uaplatform/` (all compiled artifacts)
- ✅ Simulation scripts (`.do`, `.f`)
- ✅ Memory init files (`.mem`, `.bin`, `.txt`)

---

### 3. **scripts/create-public-release.sh**
**Changes:**
- Updated `PUBLIC_DIRS` array to include new directories
- Removed `soc/` from `PUBLIC_FILES` (now a directory in `PUBLIC_DIRS`)
- Added exclusion patterns for simulation artifacts

**Updated Arrays:**

```bash
# Directories/files to include in public release
PUBLIC_DIRS=(
    "rtl/"
    "doc/"
    "plugin/"
    "testbench/"          # NEW
    "sim/"                # NEW
    "example_design/"     # NEW
)

PUBLIC_FILES=(
    "README.md"
    "QUICKSTART.md"
    "metadata.xml"
    "bus_interface.xml"
    "memory_map.xml"
    # "soc/" removed - now in PUBLIC_DIRS as example_design/
)
```

**Release Script Exclusion Patterns:**
```bash
EXCLUDE_PATTERNS=(
    "*.bak"
    "*~"
    "INTERNAL_*"
    "TODO*"
    ".DS_Store"
    # Note: Simulation artifacts (*.wlf, *.log, transcript, work/) are handled
    # by .gitignore and won't be in the repository
)
```

**Git Exclusions (.gitignore):**
```gitignore
# Simulation outputs
*.log
*.wlf
transcript

# Simulation working directories
**/sim/work/
work/

# Prebuilt libraries are NOT ignored (kept in git):
# sim/pmi/
# sim/lfmxo5/
# sim/uaplatform/
# sim/bht_ini.bin
```

---

## Directory Purpose

### `example_design/`
**Purpose:** Contains complete Radiant/Propel project examples
**Contents:**
- `.sbx` project files
- Generated IP configurations
- System-level integration examples
- BSP (Board Support Package) files
- Driver source code

**Example:**
```
example_design/
└── D6_HaperRam/
    ├── D6_HaperRam/         # Radiant/Propel project
    ├── sge/                 # Software Generation Environment
    └── verification/        # Verification setup
```

---

### `testbench/`
**Purpose:** Contains testbench files for IP verification
**Contents:**
- Top-level testbenches (`tb_top.v`)
- Memory models (`s27ks0641.v`)
- UART models
- Test stimulus files (`.mem`, `.bin`, `.txt`)

**Example:**
```
testbench/
├── tb_top.v              # Main testbench
├── s27ks0641.v           # HyperRAM memory model
├── uart/                 # UART models
├── MEM.TXT               # Memory initialization
└── reginit.bin           # Register initialization
```

---

### `sim/`
**Purpose:** Simulation scripts, memory init files, and prebuilt libraries
**Contents:**
- QuestaSim/ModelSim scripts (`.do`, `.f`)
- File lists (`flist_*.f`)
- Memory initialization files (`.mem`)
- Prebuilt library work directories (`pmi/`, `lfmxo5/`, `uaplatform/`)
- Waveform display scripts (`wave.do`)

**Example:**
```
sim/
├── qsim.do               # QuestaSim run script
├── flist_d6.f            # RTL file list
├── wave.do               # Waveform display script
├── s27ks0641.mem         # Memory init file
├── pmi/                  # PMI library (precompiled)
├── lfmxo5/               # LFMXO5 library (precompiled)
└── uaplatform/           # UART platform library (precompiled)
```

**Note:** Simulation artifacts (`.wlf`, `.log`, `bht_ini.bin`) are automatically excluded from releases.

---

## Release Behavior

### Internal Releases (`./scripts/create-public-release.sh internal "message"`)
**Includes:**
- All directories: `rtl/`, `doc/`, `plugin/`, `testbench/`, `sim/`, `example_design/`
- All files committed to git (simulation artifacts excluded via .gitignore)
- **Prebuilt libraries included** (`sim/pmi/`, `sim/lfmxo5/`, `sim/uaplatform/`)
- **`bht_ini.bin` included** (required by cpu0.v)

**Note:** Simulation artifacts (`*.wlf`, `*.log`, `transcript`, `work/`) are excluded by `.gitignore` and never committed to git.

### External Releases (`./scripts/create-public-release.sh major/minor/bugfix "message" "revision"`)
**Includes:**
- All directories: `rtl/`, `doc/`, `plugin/`, `testbench/`, `sim/`, `example_design/`
- All files committed to git (simulation artifacts excluded via .gitignore)
- **Prebuilt libraries included** (`sim/pmi/`, `sim/lfmxo5/`, `sim/uaplatform/`)
- **`bht_ini.bin` included** (required by cpu0.v)
- Revision history automatically updated in `doc/introduction.html`

**Note:** Simulation artifacts (`*.wlf`, `*.log`, `transcript`, `work/`) are excluded by `.gitignore` and never committed to git.

---

## Migration Notes

### If you had files in old `soc/` directory:
1. Move integration examples to `example_design/`
2. Move testbenches to `testbench/`
3. Move simulation scripts to `sim/`

### If you reference `soc/` in scripts:
- Update to reference `example_design/` instead
- Check for any hardcoded paths

### If you have CI/CD pipelines:
- Update paths to testbenches: `testbench/tb_top.v`
- Update paths to simulation scripts: `sim/qsim.do`

---

## Verification Checklist

Before next release:

- [ ] Verify `example_design/` contains complete project examples
- [ ] Verify `testbench/` contains all necessary testbench files and models
- [ ] Verify `sim/` contains simulation scripts and file lists
- [ ] Ensure no references to old `soc/` directory remain
- [ ] Test release script with new structure:
  ```bash
  ./scripts/create-public-release.sh internal "Test new structure"
  ```
- [ ] Verify simulation artifacts are excluded from release
- [ ] Verify prebuilt libraries are included (but not compiled artifacts)

---

## Additional Notes

### Prebuilt Libraries in `sim/`
The `sim/` directory contains precompiled library directories that are **REQUIRED** for simulation:
- `pmi/` - Lattice PMI (Parameterizable Module Instantiation) library
- `lfmxo5/` - LFMXO5 device library
- `uaplatform/` - UART platform library

**Git/Release Behavior:**
- ✅ **ALL compiled artifacts are committed to git** (`_lib*.qdb`, `_info`, `_vmake`, etc.)
- ✅ These prebuilt libraries are required for simulation to work correctly
- ✅ `bht_ini.bin` is committed to git (required by cpu0.v during simulation)
- ✅ These files are NOT excluded by `.gitignore`
- ✅ They will be included in all releases (internal and external)

**Important:** These prebuilt libraries must be committed to git and included in releases as they are dependencies for the simulation environment.

**What Gets Excluded:**
- ❌ `work/` directory - QuestaSim/ModelSim compiled working library (excluded by `.gitignore`)
- ❌ `*.wlf`, `*.log`, `transcript` - Simulation artifacts (excluded by `.gitignore`)
- Users will have prebuilt libraries (`pmi/`, `lfmxo5/`, `uaplatform/`) but will need to compile their own RTL into `work/`

---

**End of Summary**

This file can be deleted after migration is complete.

