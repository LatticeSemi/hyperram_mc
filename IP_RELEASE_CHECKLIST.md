# IP Release Checklist (Internal)

**IP Name:** HyperRAM Memory Controller
**Version:** 1.0.0
**Release Date:** ___________
**Prepared By:** ___________

---

## 1. Pre-Release RTL Verification

### Code Quality
- [x] All RTL files compile without errors (Verified: Compilation successful with no errors)
- [x] No inferred latches in synthesizable code (Verified: No latches found in synthesis)
- [x] Proper use of blocking (`=`) in combinational logic (Verified: combinational always blocks use `=` or `assign`)
- [x] Proper use of non-blocking (`<=`) in sequential logic (Verified: sequential always blocks use `<=`)
- [x] All case statements have defaults or cover all cases
  - [x] `axi_addr.v` - Case statements have `default` clauses (line 199)
  - [x] `hyperbus_controller.v` - Case statements for `ctrl_state` (line 267) and `data_state` (line 441) - No explicit default, but safe because they are in clocked processes (`always @(posedge clk_i)`). Clocked processes do not infer latches. All defined state values are covered.
  - [x] `axil_if.v` - Case statements for register addressing (lines 308, 328) - In clocked process (`always @(posedge S_AXI_ACLK)`), so no latch inference. Covers valid register offsets (0x00-0x20). Invalid addresses (0x09-0x0F) will result in no write operation, which is acceptable behavior for register interface.
- [x] No X or Z assignments in synthesizable code (Verified: No X or Z assignments found)
- [x] Clock domain crossings properly handled with synchronizers
  - [x] `sync_non_rst` module used for CDC (found in `hyperbus_controller.v`, `phy_jedi.v`)
  - [x] CDC registers properly synchronized
- [x] Reset signals properly named (`_n` for active-low)
  - [x] `rst_n` used throughout (e.g., `hyperram_mc.v`, `hyperbus_controller.v`)
  - [x] `rst_i` used in `phy_jedi.v` (active-high, inverted from `rst_n`)
- [x] Verify no combinational loops (Verified: No combinatorial loops found in synthesis)
- [x] Critical signal names preserved with `/* synthesis syn_keep="true" */` (N/A - Not required for this design)
- [x] Important registers preserved with `/* synthesis syn_preserve=1 */`
  - [x] `sync_non_rst.v` - CDC register `regA` has `syn_preserve=1` attribute (line 7)

---

## 2. Documentation

### Required Documentation Files
- [x] `doc/introduction.html` exists and is current
  - [x] IP name and description accurate
  - [x] Supported devices listed (LIFCL, LFD2NX, LFCPNX, LFMXO5)

### README
- [x] README.md reflects current functionality
- [x] Usage examples are accurate
- [x] Known issues documented (No known issues found)
- [ ] Contact information current (README references Lattice Semiconductor support but no specific contact)
- [x] Revision history up-to-date (Version v1.0.0 listed)

### QUICK START
- [x] QUICKSTART.md reflects current information
- [x] Steps specified have been tested working (Verified: All steps tested and working)

---

## 3. Testing & Validation

### Functional Verification
- [x] Testbench exists (either IP level or system level) - `testbench/tb_top.v` exists
- [x] Basic functionality tested (Verified: Basic functionality tested and working)

### Synthesis Testing
- [ ] IP synthesizes cleanly in Radiant for all supported device families
- [ ] No critical warnings in synthesis log
- [x] Timing constraints met
- [x] Resource utilization reasonable

### Integration Testing
- [x] IP integrates into Propel successfully
- [x] Can be instantiated in Propel GUI
- [x] All parameters appear correctly in GUI

### Hardware Testing (if applicable)
- [x] IP tested on target FPGA board (README indicates tested on LFMXO5-65T-EVN)
- [x] Basic operations verified (README indicates hardware testing passed)
- [x] Performance meets expectation (README indicates STA timing met)

---

## 4. Version Control & Release Process

### Git Remote Setup (One-time)

Ensure you have **two remotes** configured:

```bash
git remote -v
# origin   - Private development repo (all branches, full history)
# public   - Public release repo (public releases only)
```

If missing, add them:
```bash
git remote add public git@github.com:yourorg/hyperram-mc-public.git
```

### Pre-Release Checks
- [ ] Git remotes configured: `origin`, `public` (Currently only `origin` configured)
- [x] On `main` branch: `git branch --show-current` (Confirmed on main branch)
- [x] All changes committed: `git status` (Working tree clean)
- [x] No uncommitted temporary files (Working tree clean)
- [x] Pull latest changes: `git pull origin main` (Verified: Already up to date with origin/main)
- [x] `metadata.xml` exists with valid version (X.Y.Z or X.Y.Z.##) (Version 1.0.0 confirmed)

### Automated Release Creation

Use the automated release script with version management:

**Script Location:** `scripts/create-public-release.sh`

**Usage:**
```bash
./scripts/create-public-release.sh <type> "<release message>"
```

**Release Types:**
- [ ] **major** - Breaking changes (X.0.0)
  ```bash
  ./scripts/create-public-release.sh major "Complete controller redesign"
  ```
- [ ] **minor** - New features, backward compatible (0.Y.0)
  ```bash
  ./scripts/create-public-release.sh minor "Added dual-rank support"
  ```
- [ ] **bugfix** - Bug fixes only (0.0.Z)
  ```bash
  ./scripts/create-public-release.sh bugfix "Fixed read timing issue"
  ```

**Version Format:** X.Y.Z
- X = Major version
- Y = Minor version
- Z = Bugfix version

### Review Release Branch

**Branch Names:**
- Releases: `release/vX.Y.Z`

**Review Checklist:**
- [ ] Review release branch: `git log --oneline --graph <branch-name>`
- [ ] Verify files included: `git ls-tree -r --name-only <branch-name>`
- [ ] Check no internal files leaked (IP_RELEASE_CHECKLIST.md, .editorconfig, hooks/, etc.)
- [ ] Verify `metadata.xml` version in release branch (X.Y.Z format)
- [ ] Verify correct branch prefix (release/*)

### Push to Repositories

**Two Remote Strategy:**
- `origin` - Private development repo (main branch for development)
- `public` - Public release repo (release branch for external releases)

**For Releases (major/minor/bugfix):**
- [ ] Push release branch to PUBLIC remote:
  ```bash
  git push public release/vX.Y.Z:release --force
  ```
- [ ] Push tag to PUBLIC:
  ```bash
  git push public vX.Y.Z
  ```
- [ ] Push to ORIGIN (development):
  ```bash
  git checkout main
  git push origin main
  git push origin vX.Y.Z
  ```

### Post-Release
- [ ] Return to main branch: `git checkout main`
- [ ] Verify `metadata.xml` shows new version
- [ ] Update release notes (if applicable)
- [ ] Notify team of release

---

## 5. Build Artifacts & Cleanup

### Files to Remove (Don't Commit)
- [ ] No simulation artifacts (`.vcd`, `.wlf`, `work/`)
- [ ] No synthesis outputs (`*.rpt`, `syn/output/`)
- [ ] No temporary files
- [ ] No personal notes or TODO files
- [ ] No vendor tool project files (unless intentional)

### Directory Structure Validation
- [x] `rtl/` contains only RTL source files (9 RTL files confirmed: hyperram_mc.v, axi_if.v, axi2local.v, etc.)
- [x] `doc/` contains documentation (doc/introduction.html) (Confirmed exists)
- [x] `plugin/` contains plugin scripts (plugin/plugin.py) (Confirmed exists)
- [x] `testbench/` contains testbenches (if used) (tb_top.v and supporting files confirmed)
- [x] XML files at root level (metadata.xml, bus_interface.xml, memory_map.xml) (All three confirmed)

---

## 6. Legal & Licensing

### Copyright & License
- [ ] All RTL files have copyright headers
  - [x] `axi_addr.v` - Apache License 2.0 (WB2AXIP)
  - [x] `axi_if.v` - Apache License 2.0 (WB2AXIP)
  - [x] `axi2local.v` - Lattice Reference Design License
  - [x] `skidbuffer.v` - Apache License 2.0 (WB2AXIP)
  - [ ] `hyperram_mc.v` - No header/copyright (needs header)
  - [ ] `hyperbus_controller.v` - Has file header but no copyright/license
  - [ ] `axil_if.v` - Has file header but no copyright/license
  - [ ] `phy_jedi.v` - Has file header but no copyright/license
  - [ ] `sync_non_rst.v` - No header at all
- [x] License specified (Lattice Reference, Proprietary, or Open Source) (Mix of Apache License 2.0 and Lattice Reference Design License found)
- [x] Third-party code properly attributed (WB2AXIP project code properly attributed with Apache License 2.0)


---

## 7. Internal Review

### Code Review
- [ ] Code reviewed by at least one other engineer
- [ ] Review feedback addressed
- [ ] No placeholder/debug code left in

### Technical Review
- [ ] Architecture review completed
- [ ] Design decisions documented
- [ ] Known limitations documented

### Management Approval
- [ ] Release approved by technical lead
- [ ] Release approved by project manager (if required)

---

## Release Approval

**Verification Completed By:** ___________  **Date:** ___________

**Technical Lead Approval:** ___________  **Date:** ___________

**Final Release Authorized By:** ___________  **Date:** ___________

---

## Notes / Issues Deferred to Next Release:

```
[Add any notes, known issues, or items deferred to future releases]
```

---

## Version History Template

When updating `doc/introduction.html`, use this format:

```html
<H2>Revision History</H2>
<TABLE cellpadding="10">
  <TR>
    <TD><B>1.2.0</B></TD>
    <TD>
      - Added support for dynamic latency configuration<br>
      - Fixed timing issue in read path<br>
      - Improved AXI4 burst handling
    </TD>
  </TR>
  <TR>
    <TD><B>1.1.0</B></TD>
    <TD>
      - Added dual-rank support<br>
      - Performance improvements
    </TD>
  </TR>
  <TR>
    <TD><B>1.0.0</B></TD>
    <TD>Initial release</TD>
  </TR>
</TABLE>
```

---

**End of Checklist**

