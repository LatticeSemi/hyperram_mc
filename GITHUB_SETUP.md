# GitHub Setup Guide

Quick setup guide for enabling CI/CD and branch protection.

---

## **✅ Step 1: Enable GitHub Actions**

1. Go to repository on GitHub
2. Click **Settings** tab
3. Click **Actions** → **General**
4. Under "Actions permissions":
   - ✅ Select "Allow all actions and reusable workflows"
5. Click **Save**

---

## **✅ Step 2: Configure Branch Protection for Main**

1. Go to **Settings** → **Branches**
2. Click **Add branch protection rule**
3. **Branch name pattern:** `main`

### **Require Pull Request**
- ✅ **Require a pull request before merging**
  - ✅ **Require approvals:** `1`
  - ✅ **Dismiss stale pull request approvals when new commits are pushed**
  - ✅ **Require review from Code Owners** (optional)

### **Require Status Checks**
- ✅ **Require status checks to pass before merging**
  - ✅ **Require branches to be up to date before merging**
  - **Status checks that are required:**
    - ✅ `Code Quality Checks`
    - ✅ `RTL Lint (Verilator)`
    - ✅ `XML Validation`
    - ✅ `Version Format Check`
    - ✅ `RTL Simulation`
    - ✅ `PR Status Summary`

### **Additional Rules**
- ✅ **Require conversation resolution before merging**
- ✅ **Require signed commits** (optional, recommended)
- ✅ **Require linear history** (for fast-forward merges)
- ✅ **Include administrators** (even admins must follow rules)

4. Click **Create** or **Save changes**

---

## **✅ Step 3: Set Default Merge Strategy**

1. Go to **Settings** → **General**
2. Scroll to **Pull Requests** section
3. Configure **Merge button:**
   - ✅ **Allow merge commits** (default, fast-forward when possible)
   - ✅ **Allow squash merging** (option for cleaner history)
   - ❌ **Allow rebase merging** (optional, not recommended)

4. **Default to:** "Merge commit"
5. Click **Save**

---

## **✅ Step 4: Install GitHub CLI (Optional but Recommended)**

### **Windows:**
```powershell
# Using winget
winget install --id GitHub.cli

# Or using Chocolatey
choco install gh

# Or download from https://cli.github.com/
```

### **Linux:**
```bash
# Ubuntu/Debian
sudo apt install gh

# Or download from https://cli.github.com/
```

### **Authenticate:**
```bash
gh auth login
```

### **Verify:**
```bash
gh repo view
```

---

## **✅ Step 5: Test the Setup**

### **Test PR Workflow:**
```bash
# Create test feature branch
git checkout -b test/ci-setup

# Make small change
echo "# Test CI" >> README.md
git add README.md
git commit -m "Test: CI pipeline setup"

# Push to remote
git push origin test/ci-setup

# Create PR on GitHub
# - Go to repository → Pull requests → New pull request
# - Base: main ← Compare: test/ci-setup
# - Click "Create pull request"

# Watch automated checks run!
```

### **Expected PR Checks:**
```
✅ Code Quality Checks - passed
✅ RTL Lint (Verilator) - passed
✅ XML Validation - passed
✅ Version Format Check - passed
✅ RTL Simulation - passed
✅ PR Status Summary - passed
```

### **Test Merge:**
1. Request review from teammate
2. Wait for approval
3. Click "Merge pull request"
4. Choose merge strategy (merge commit or squash)
5. Confirm merge
6. Watch CI pipeline run on main!

---

## **✅ Step 6: Setup Simulation (Optional)**

### **Option A: Use Placeholder (for setup)**
Current workflow files include placeholders for simulation.
- ✅ Workflows will pass
- ⚠️ Not running actual simulation yet

### **Option B: Add Self-Hosted Runner**

1. **Settings** → **Actions** → **Runners** → **New self-hosted runner**
2. Follow instructions to setup runner on machine with QuestaSim/ModelSim
3. Update `.github/workflows/pr-checks.yml`:
   ```yaml
   rtl-simulation:
     runs-on: self-hosted  # Change from ubuntu-latest
   ```
4. Add actual simulation script

### **Option C: Use Docker Container**
```yaml
rtl-simulation:
  runs-on: ubuntu-latest
  container:
    image: your-registry/questa-sim:latest
```

---

## **✅ Step 7: Configure CI Status Check for Internal Publish**

The release script (`scripts/create-public-release.sh`) will automatically check CI status before allowing internal publish.

**Requires:**
- ✅ GitHub CLI installed (`gh`)
- ✅ Authenticated (`gh auth login`)
- ✅ CI must pass on main before internal publish

**Test:**
```bash
# After merging PR to main, wait for CI to complete
gh run list --branch main

# When CI passes, can do internal publish
git checkout main
git pull origin main
./scripts/create-public-release.sh internal "Internal test build"
```

---

## **✅ Step 8: Setup Git Remotes (Three-Remote Strategy)**

### **Current Remote (origin):**
```bash
git remote -v
# origin  https://github.com/LSCC-SoftIP/hyperram_mc.git
```

### **Add Staging Remote (Internal Releases):**
```bash
# Create staging repository on GitHub (private)
# Then add remote:
git remote add staging git@github.com:LSCC-SoftIP/hyperram-mc-staging.git

# Or if using HTTPS:
git remote add staging https://github.com/LSCC-SoftIP/hyperram-mc-staging.git
```

### **Add Public Remote (External Releases):**
```bash
# Create public repository on GitHub (can be public or private)
# Then add remote:
git remote add public git@github.com:LSCC-SoftIP/hyperram-mc-public.git

# Or if using HTTPS:
git remote add public https://github.com/LSCC-SoftIP/hyperram-mc-public.git
```

### **Verify All Remotes:**
```bash
git remote -v

# Expected output:
# origin   git@github.com:LSCC-SoftIP/hyperram_mc.git (fetch)
# origin   git@github.com:LSCC-SoftIP/hyperram_mc.git (push)
# staging  git@github.com:LSCC-SoftIP/hyperram-mc-staging.git (fetch)
# staging  git@github.com:LSCC-SoftIP/hyperram-mc-staging.git (push)
# public   git@github.com:LSCC-SoftIP/hyperram-mc-public.git (fetch)
# public   git@github.com:LSCC-SoftIP/hyperram-mc-public.git (push)
```

---

## **📋 Setup Checklist**

- [ ] GitHub Actions enabled
- [ ] Branch protection configured for `main`
- [ ] Required status checks selected
- [ ] Pull request reviews required (min 1 approval)
- [ ] Merge strategy configured (merge commit default)
- [ ] GitHub CLI installed and authenticated
- [ ] Test PR created and merged successfully
- [ ] CI pipeline tested on main
- [ ] Simulation configured (or placeholder confirmed)
- [ ] Staging remote added
- [ ] Public remote added
- [ ] All remotes verified

---

## **🎯 Quick Reference**

### **Create Feature Branch:**
```bash
git checkout main
git pull origin main
git checkout -b feature/my-feature
```

### **Create Pull Request:**
```bash
git push origin feature/my-feature
# Then create PR on GitHub
```

### **Internal Publish:**
```bash
git checkout main
git pull origin main
./scripts/create-public-release.sh internal "Message"
git push staging staging/vX.Y.Z.##:main --force
git push staging vX.Y.Z.##
```

### **External Publish:**
```bash
git checkout staging/vX.Y.Z.##
git pull staging main
./scripts/create-public-release.sh bugfix "Message" "Description"
git push public release/vX.Y.Z:main --force
git push public vX.Y.Z
```

---

## **📚 See Also**

- [DEVELOPMENT_WORKFLOW.md](DEVELOPMENT_WORKFLOW.md) - Complete workflow guide
- [.github/workflows/README.md](.github/workflows/README.md) - CI/CD documentation
- [scripts/README.md](scripts/README.md) - Release scripts
- [IP_RELEASE_CHECKLIST.md](IP_RELEASE_CHECKLIST.md) - Release checklist

