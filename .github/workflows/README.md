# GitHub Actions Workflows

CI/CD pipelines for HyperRAM Memory Controller IP.

---

## **Workflows**

### **1. pr-checks.yml** - Pull Request Checks

**Triggers:** When PR is opened/updated to `main` branch

**Jobs:**
1. **Code Quality** - Whitespace, tabs, line endings
2. **RTL Lint** - Verilator lint checks
3. **XML Validation** - Validate IP metadata
4. **Version Check** - Validate version format
5. **RTL Simulation** - QuestaSim/ModelSim simulation
6. **Documentation** - Check required docs exist

**Required for:** PR approval and merge

---

### **2. ci-main.yml** - CI Pipeline (Main Branch)

**Triggers:** Push to `main` branch (after PR merge)

**Jobs:**
1. **Full Lint** - Comprehensive RTL lint
2. **Full Simulation** - Complete regression test suite
3. **Integration Tests** - Integration test suite
4. **Build Artifacts** - Create and archive build artifacts
5. **CI Status** - Gate for internal publish (BLOCKS if failed)

**Purpose:** Ensure main branch is always releasable

---

## **🔧 Simulation Setup**

### **Option 1: Self-Hosted Runner (Recommended)**

**For production use with QuestaSim/ModelSim:**

1. **Setup self-hosted runner:**
   ```bash
   # On machine with QuestaSim/ModelSim installed
   # Settings → Actions → Runners → New self-hosted runner
   ```

2. **Update workflow to use self-hosted runner:**
   ```yaml
   rtl-simulation:
     runs-on: self-hosted
     steps:
       - name: Run simulation
         run: |
           vlib work
           vlog rtl/*.v testbench/*.sv
           vsim -c -do "run -all; quit" work.tb_top
   ```

3. **Advantages:**
   - ✅ Full access to commercial tools
   - ✅ Faster simulation
   - ✅ Access to local files/licenses

---

### **Option 2: Docker Container**

**Use Docker image with simulation tools:**

```yaml
rtl-simulation:
  runs-on: ubuntu-latest
  container:
    image: your-registry/questa-sim:latest
  steps:
    - name: Run simulation
      run: |
        vlib work
        vlog rtl/*.v testbench/*.sv
        vsim -c -do "run -all; quit" work.tb_top
```

---

### **Option 3: Cloud Simulation Service**

**Use cloud-based EDA tools (if available):**
- Metrics Cloud
- Cadence Cloud
- Synopsys Cloud

---

## **📝 Simulation Script Example**

### **scripts/run_simulation.sh**

```bash
#!/bin/bash
# RTL Simulation Script for CI/CD

set -e

# Setup
echo "Setting up simulation..."
vlib work

# Compile RTL
echo "Compiling RTL..."
vlog -sv rtl/hyperram_mc.v rtl/*.v

# Compile testbench
echo "Compiling testbench..."
vlog -sv testbench/tb_top.sv

# Run simulation
echo "Running simulation..."
vsim -c -do "run -all; coverage report; quit -f" work.tb_top

# Check results
if [ -f "simulation.log" ]; then
    if grep -q "FAIL" simulation.log; then
        echo "❌ Simulation FAILED"
        exit 1
    else
        echo "✅ Simulation PASSED"
        exit 0
    fi
else
    echo "❌ Simulation log not found"
    exit 1
fi
```

---

## **🎯 Quick Setup Checklist**

### **For PR Checks:**
- [ ] Enable GitHub Actions in repository settings
- [ ] Configure simulation runner (self-hosted or Docker)
- [ ] Add simulation script (run_simulation.sh)
- [ ] Test PR check workflow

### **For CI Pipeline:**
- [ ] Setup self-hosted runner with simulation tools
- [ ] Configure license servers (if needed)
- [ ] Add comprehensive test suite
- [ ] Setup artifact storage

### **For Branch Protection:**
- [ ] Settings → Branches → Add rule for `main`
- [ ] Require PR reviews (minimum 1 approval)
- [ ] Require status checks:
  - [ ] Code Quality Checks
  - [ ] RTL Lint (Verilator)
  - [ ] XML Validation
  - [ ] Version Format Check
  - [ ] RTL Simulation
  - [ ] Documentation Check

---

## **🚀 Testing the Workflows**

### **Test PR Checks:**
```bash
# Create test feature branch
git checkout -b test/ci-setup

# Make small change
echo "# Test" >> README.md
git add README.md
git commit -m "Test CI pipeline"

# Push and create PR
git push origin test/ci-setup
# Create PR on GitHub
```

### **Test CI Pipeline:**
```bash
# Merge a PR to main
# CI will trigger automatically
# Monitor: gh run list --branch main
```

---

## **📊 Monitoring**

### **View Workflow Runs:**
```bash
# List recent runs
gh run list

# View specific run
gh run view <run-id>

# Watch run in real-time
gh run watch <run-id>

# View logs
gh run view <run-id> --log
```

### **Check CI Status:**
```bash
# Check status for main branch
gh api repos/{owner}/{repo}/commits/main/status

# Or using release script
./scripts/create-public-release.sh internal "Test"
# Script will check CI automatically
```

---

## **🔒 Secrets Management**

### **Add Secrets (if needed):**

**Settings → Secrets and variables → Actions → New repository secret**

**Common secrets:**
- `LICENSE_SERVER` - License server URL
- `DOCKER_USERNAME` - Docker registry credentials
- `DOCKER_PASSWORD` - Docker registry credentials

**Use in workflow:**
```yaml
env:
  LICENSE_SERVER: ${{ secrets.LICENSE_SERVER }}
```

---

## **📚 Resources**

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners)
- [GitHub CLI](https://cli.github.com/)
- [Development Workflow](../../DEVELOPMENT_WORKFLOW.md)

