# Development Workflow

Complete development workflow for HyperRAM Memory Controller IP.

---

## **🔄 Development Flow Overview**

```
Feature Branch → Pull Request → Main Branch → CI Pipeline → Internal Publish → External Publish
     ↓              ↓              ↓              ↓                ↓                   ↓
  Develop    Review + Sim    Fast-forward    Full CI         Staging           Release
              Required         Merge          Gate            Branch            Branch
```

---

## **📋 Step-by-Step Workflow**

### **Phase 1: Feature Development**

#### **Step 1: Get Latest from Main**
```bash
# Ensure you're on main
git checkout main

# Pull latest changes
git pull origin main
```

#### **Step 2: Create Feature Branch**
```bash
# Create and switch to feature branch
git checkout -b feature/your-feature-name

# Or use git branch then switch
git branch feature/your-feature-name
git checkout feature/your-feature-name
```

**Branch Naming Convention:**
- `feature/add-dual-rank-support`
- `feature/improve-timing`
- `bugfix/fix-read-timing`
- `enhancement/optimize-latency`

#### **Step 3: Make Changes**
```bash
# Edit files
vim rtl/hyperram_mc.v

# Check status
git status

# Stage changes
git add rtl/hyperram_mc.v

# Commit locally (DO NOT merge to main directly!)
git commit -m "Add dual-rank HyperRAM support"
```

**Important:**
- ❌ **NEVER** `git merge` to main locally
- ❌ **NEVER** `git push` directly to main
- ✅ **ALWAYS** commit to feature branch only

#### **Step 4: Push Feature Branch to Remote**
```bash
# Push feature branch to remote
git push origin feature/your-feature-name

# If first time pushing this branch
git push -u origin feature/your-feature-name
```

---

### **Phase 2: Pull Request & Review**

#### **Step 5: Create Pull Request**

**On GitHub:**
1. Go to repository page
2. Click **"Pull requests"** tab
3. Click **"New pull request"**
4. **Base:** `main` ← **Compare:** `feature/your-feature-name`
5. Fill in PR description:
   ```markdown
   ## Description
   Brief description of changes

   ## Changes Made
   - List of changes

   ## Testing Done
   - Simulation results
   - Lint checks

   ## Related Issues
   Fixes #123
   ```
6. Click **"Create pull request"**

#### **Step 6: Automated Checks (PR Pipeline)**

**GitHub Actions automatically runs:**
- ✅ Code quality checks (whitespace, tabs, line endings)
- ✅ RTL lint (Verilator)
- ✅ XML validation
- ✅ Version format check
- ✅ RTL simulation (QuestaSim/ModelSim)
- ✅ Documentation check

**Status will show in PR:**
```
✅ Code Quality Checks passed
✅ RTL Lint passed
✅ XML Validation passed
✅ RTL Simulation passed
```

**If checks fail:** Fix issues and push new commits:
```bash
# Fix issues
git add .
git commit -m "Fix lint issues"
git push origin feature/your-feature-name
# PR checks will re-run automatically
```

#### **Step 7: Peer Review**

**Reviewer actions:**
1. Review code changes
2. Add comments/suggestions
3. Request changes OR approve

**Developer actions:**
```bash
# Address review comments
git add .
git commit -m "Address review comments"
git push origin feature/your-feature-name
```

**PR is ready when:**
- ✅ All automated checks passed
- ✅ Simulation passed
- ✅ At least 1 approval from reviewer
- ✅ No unresolved comments

---

### **Phase 3: Merging to Main**

#### **Step 8: Merge Pull Request**

**Default: Fast-Forward Merge**
```
feature commits → main (linear history)
```

**GitHub Settings:**
- **Default:** "Create a merge commit" (fast-forward when possible)
- **Option:** "Squash and merge" (single commit)

**On GitHub:**
1. Click **"Merge pull request"**
2. Choose merge strategy:
   - **Merge commit** (default, preserves all commits)
   - **Squash and merge** (single commit, cleaner history)
3. Click **"Confirm merge"**
4. Click **"Delete branch"** (cleanup)

**After merge:**
```bash
# Local cleanup
git checkout main
git pull origin main
git branch -d feature/your-feature-name  # Delete local feature branch
```

---

### **Phase 4: CI Pipeline (Automatic)**

#### **Step 9: CI Runs Automatically**

**Triggered by:** Push to main (after PR merge)

**CI Pipeline runs:**
- ✅ Full RTL lint
- ✅ Full simulation suite
- ✅ Integration tests
- ✅ Build artifacts
- ✅ Coverage analysis

**CI Status Options:**
- ✅ **SUCCESS** → Internal publish allowed
- ❌ **FAILURE** → Internal publish BLOCKED

**Check CI status:**
```bash
# Using GitHub CLI
gh run list --branch main

# View specific run
gh run view <run-id>
```

**If CI fails:**
1. Review failure logs
2. Create fix in new feature branch
3. Follow PR process again
4. CI must pass before internal publish

---

### **Phase 5: Internal Publish (Staging)**

#### **Step 10: Prepare for Internal Publish**

**Prerequisites:**
- ✅ On main branch
- ✅ Latest changes pulled
- ✅ CI pipeline PASSED

```bash
# Ensure on main
git checkout main

# Pull latest (includes merged PR)
git pull origin main
```

#### **Step 11: Run Internal Publish Script**

```bash
# Internal release (adds .## counter)
./scripts/create-public-release.sh internal "Internal testing build for QA"
```

**Script will:**
1. ✅ Check CI status (BLOCKS if failed!)
2. ✅ Read version from metadata.xml (e.g., 1.0.0)
3. ✅ Increment internal counter (e.g., 1.0.0 → 1.0.0.01)
4. ✅ Update metadata.xml on main
5. ✅ Create `staging/v1.0.0.01` branch
6. ✅ Copy only public files
7. ✅ Create commit and tag

**Output:**
```
========================================
Release Summary
========================================
Type:           internal
Current:        1.0.0
New Version:    1.0.0.01
Release Tag:    v1.0.0.01
Target Remote:  staging
Branch Prefix:  staging
Public Release: false
========================================

CI status: PASSED ✅
```

#### **Step 12: Push to Staging Remote**

```bash
# Push staging branch to staging remote
git push staging staging/v1.0.0.01:main --force

# Push tag
git push staging v1.0.0.01

# Return to main
git checkout main
```

---

### **Phase 6: External Publish (Release)**

#### **Step 13: Prepare for External Release**

```bash
# Switch to staging branch
git checkout staging/v1.0.0.02  # Latest staging version

# Pull latest from staging remote
git pull staging main
```

#### **Step 14: Create External Release**

```bash
# External release (drops .## counter, requires revision description)
./scripts/create-public-release.sh bugfix \
  "Fixed read timing violation" \
  "Fixed read timing violation in high-speed mode"
```

**Script will:**
1. ✅ Read version from metadata.xml (e.g., 1.0.0.02)
2. ✅ Increment version based on type (e.g., 1.0.0.02 → 1.0.1)
3. ✅ Drop internal counter (1.0.1, not 1.0.1.00)
4. ✅ Update metadata.xml
5. ✅ Update doc/introduction.html revision history
6. ✅ Create `release/v1.0.1` branch
7. ✅ Create commit and tag

#### **Step 15: Push to Public Remote**

```bash
# Push release branch to public remote
git push public release/v1.0.1:main --force

# Push tag
git push public v1.0.1

# Return to main
git checkout main
```

---

## **🛡️ Branch Protection Rules**

### **Main Branch Protection**

**Settings → Branches → Add Rule:**

- ✅ **Require pull request before merging**
  - Require approvals: **1**
  - Dismiss stale reviews when new commits are pushed

- ✅ **Require status checks to pass**
  - Require branches to be up to date
  - Status checks required:
    - `Code Quality Checks`
    - `RTL Lint (Verilator)`
    - `XML Validation`
    - `Version Format Check`
    - `RTL Simulation`
    - `Documentation Check`

- ✅ **Require conversation resolution**

- ✅ **Do not allow bypassing** (even admins must follow process)

---

## **📊 Complete Flow Diagram**

```
┌─────────────────────────────────────────────────────────────────┐
│  Developer Workflow                                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. git checkout main                                           │
│  2. git pull origin main                                        │
│  3. git checkout -b feature/my-feature                          │
│  4. [Make changes]                                              │
│  5. git commit -m "..." (local only!)                           │
│  6. git push origin feature/my-feature                          │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  Pull Request (GitHub)                                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  7. Create PR: feature/my-feature → main                        │
│  8. Automated checks run:                                       │
│     - Code quality ✅                                           │
│     - RTL lint ✅                                               │
│     - Simulation ✅                                             │
│  9. Peer review + approval ✅                                   │
│ 10. Merge to main (fast-forward or squash)                     │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  CI Pipeline (Automatic)                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ 11. CI triggers on main push                                    │
│ 12. Full simulation suite ✅                                    │
│ 13. Integration tests ✅                                        │
│ 14. CI status: PASSED → Allow internal publish                 │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  Internal Publish (Staging)                                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ 15. git checkout main && git pull origin main                   │
│ 16. ./scripts/create-public-release.sh internal "msg"          │
│     - CI check: Must be PASSED ✅                              │
│     - Version: 1.0.0 → 1.0.0.01                                │
│     - Creates: staging/v1.0.0.01                               │
│ 17. git push staging staging/v1.0.0.01:main --force            │
│ 18. git push staging v1.0.0.01                                  │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  External Publish (Release)                                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ 19. git checkout staging/v1.0.0.02                             │
│ 20. git pull staging main                                       │
│ 21. ./scripts/create-public-release.sh bugfix "..." "desc"     │
│     - Version: 1.0.0.02 → 1.0.1 (drops .##)                    │
│     - Creates: release/v1.0.1                                  │
│     - Updates: doc/introduction.html                           │
│ 22. git push public release/v1.0.1:main --force                │
│ 23. git push public v1.0.1                                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## **🚨 Important Rules**

### **DO:**
- ✅ Always create feature branches
- ✅ Always use pull requests
- ✅ Always wait for CI to pass
- ✅ Always get peer review
- ✅ Check CI status before internal publish

### **DON'T:**
- ❌ Never push directly to main
- ❌ Never merge locally to main
- ❌ Never bypass pull request process
- ❌ Never publish internally if CI failed
- ❌ Never skip simulation checks

---

## **🔧 Setup Requirements**

### **GitHub CLI (Recommended)**
```bash
# Install GitHub CLI
# https://cli.github.com/

# Authenticate
gh auth login

# Verify
gh repo view
```

### **Git Remotes**
```bash
# View remotes
git remote -v

# Expected:
# origin  - Private development (all branches)
# staging - Private internal (staging/* branches)
# public  - Public release (release/* branches)
```

---

## **📚 See Also**

- [scripts/README.md](scripts/README.md) - Release script documentation
- [IP_RELEASE_CHECKLIST.md](IP_RELEASE_CHECKLIST.md) - Release checklist
- [.github/workflows/](..github/workflows/) - CI/CD pipelines

