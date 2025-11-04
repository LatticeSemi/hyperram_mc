# IP Release Checklist (Internal)

**IP Name:** HyperRAM Memory Controller
**Version:** ___________
**Release Date:** ___________
**Prepared By:** ___________

---

## 1. Pre-Release RTL Verification

### Code Quality
- [ ] All RTL files compile without errors
- [ ] No inferred latches in synthesizable code
- [ ] Proper use of blocking (`=`) in combinational logic
- [ ] Proper use of non-blocking (`<=`) in sequential logic
- [ ] All case statements have defaults or cover all cases
- [ ] No X or Z assignments in synthesizable code
- [ ] Clock domain crossings properly handled with synchronizers
- [ ] Reset signals properly named (`_n` for active-low)
- [ ] Check for unused signals/ports
- [ ] Check for undriven outputs
- [ ] Verify no combinational loops
- [ ] Critical signal names preserved with `/* synthesis syn_keep="true" */`
- [ ] Important registers preserved with `/* synthesis syn_preserve=1 */`

---

## 2. Documentation

### Required Documentation Files
- [ ] `doc/introduction.html` exists and is current
  - [ ] IP name and description accurate
  - [ ] Supported devices listed (LIFCL family)

### README
- [ ] README.md reflects current functionality
- [ ] Usage examples are accurate
- [ ] Known issues documented
- [ ] Contact information current
- [ ] Revision history up-to-date

### QUICK START
- [ ] QUICKSTART.md reflects current information
- [ ] Steps specified have been tested working

---

## 3. Testing & Validation

### Functional Verification
- [ ] Testbench exists (either IP level or system level)
- [ ] Basic functionality tested

### Synthesis Testing
- [ ] IP synthesizes cleanly in Radiant for all supported device families
- [ ] No critical warnings in synthesis log
- [ ] Timing constraints met
- [ ] Resource utilization reasonable

### Integration Testing
- [ ] IP integrates into Propel successfully
- [ ] Can be instantiated in Propel GUI
- [ ] All parameters appear correctly in GUI

### Hardware Testing (if applicable)
- [ ] IP tested on target FPGA board
- [ ] Basic operations verified
- [ ] Performance meets expectation

---

## 4. Version Control & Release Process

### Git Remote Setup (One-time)

Ensure you have **three remotes** configured:

```bash
git remote -v
# origin   - Private development repo (all branches, full history)
# staging  - Private internal staging repo (internal releases only)
# public   - Public release repo (public releases only)
```

If missing, add them:
```bash
git remote add staging git@private-server:yourorg/hyperram-mc-staging.git
git remote add public git@github.com:yourorg/hyperram-mc-public.git
```

### Pre-Release Checks
- [ ] Git remotes configured: `origin`, `staging`, `public`
- [ ] On `main` branch: `git branch --show-current`
- [ ] All changes committed: `git status`
- [ ] No uncommitted temporary files
- [ ] `.gitignore` up to date
- [ ] Pull latest changes: `git pull origin main`
- [ ] VERSION file exists and is readable

### Automated Release Creation

Use the automated release script with version management:

**Script Location:** `scripts/create-public-release.sh`

**Usage:**
```bash
./scripts/create-public-release.sh <type> "<release message>"
```

**Release Types:**
- [ ] **major** - Breaking changes (X.0.0.00)
  ```bash
  ./scripts/create-public-release.sh major "Complete controller redesign"
  ```
- [ ] **minor** - New features, backward compatible (0.Y.0.00)
  ```bash
  ./scripts/create-public-release.sh minor "Added dual-rank support"
  ```
- [ ] **bugfix** - Bug fixes only (0.0.Z.00)
  ```bash
  ./scripts/create-public-release.sh bugfix "Fixed read timing issue"
  ```
- [ ] **internal** - Internal testing (0.0.0.##)
  ```bash
  ./scripts/create-public-release.sh internal "Internal test build"
  ```

**Version Format:** X.Y.Z.##
- X = Major version
- Y = Minor version
- Z = Bugfix version
- ## = Internal counter (2 digits)

### Review Release Branch

**Branch Names by Type:**
- Public releases: `release/vX.Y.Z.##`
- Internal releases: `staging/vX.Y.Z.##`

**Review Checklist:**
- [ ] Review release branch: `git log --oneline --graph <branch-name>`
- [ ] Verify files included: `git ls-tree -r --name-only <branch-name>`
- [ ] Check no internal files leaked (IP_RELEASE_CHECKLIST.md, .editorconfig, hooks/, etc.)
- [ ] Verify metadata.xml version updated (public releases: X.Y.Z, internal: X.Y.Z.##)
- [ ] Verify VERSION file in release branch
- [ ] Verify correct branch prefix (release/* or staging/*)

### Push to Repositories

**Three Remote Strategy:**
- `origin` - Private development repo (all branches)
- `staging` - Private internal staging repo (internal releases)
- `public` - Public release repo (public releases only)

**For Public Releases (major/minor/bugfix):**
- [ ] Push release branch to PUBLIC remote:
  ```bash
  git push public release/vX.Y.Z.##:main --force
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
- [ ] Optionally push tag to STAGING for record:
  ```bash
  git push staging vX.Y.Z
  ```

**For Internal Releases:**
- [ ] Push release branch to STAGING remote:
  ```bash
  git push staging staging/vX.Y.Z.##:main --force
  ```
- [ ] Push tag to STAGING:
  ```bash
  git push staging vX.Y.Z.##
  ```
- [ ] Push to ORIGIN (development):
  ```bash
  git checkout main
  git push origin main
  git push origin vX.Y.Z.##
  ```
- [ ] **DO NOT** push to PUBLIC (this is internal only)

### Post-Release
- [ ] Return to main branch: `git checkout main`
- [ ] Verify VERSION file shows new version
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
- [ ] `rtl/` contains only RTL source files
- [ ] `doc/` contains documentation (doc/introduction.html)
- [ ] `plugin/` contains plugin scripts (plugin/plugin.py)
- [ ] `testbench/` contains testbenches (if used)
- [ ] XML files at root level (metadata.xml, bus_interface.xml, memory_map.xml)

---

## 6. Legal & Licensing

### Copyright & License
- [ ] All RTL files have copyright headers
- [ ] License specified (Lattice Reference, Proprietary, or Open Source)
- [ ] Third-party code properly attributed


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

