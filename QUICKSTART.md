# HyperRAM Memory Controller - Quick Start Guide

This guide provides step-by-step instructions to quickly run simulations and generate bitstreams for the HyperRAM Memory Controller IP.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Running Simulation](#running-simulation)
  - [Standard Simulation Flow](#standard-simulation-flow)
  - [Simulation After IP Regeneration](#simulation-after-ip-regeneration)
- [Generating Bitstream for Hardware](#generating-bitstream-for-hardware)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before you begin, ensure you have the following tools installed:

- **QuestaSim/ModelSim** - For RTL simulation
- **Lattice Propel** - For SoC integration and IP configuration
- **Lattice Radiant** - For FPGA synthesis and bitstream generation
- **Git** - For cloning the repository

---

## Running Simulation

### Standard Simulation Flow

Use this flow if you're working with the repository as-is without regenerating the HyperRAM IP.

**Steps:**

1. **Clone the repository to your local machine:**
   ```bash
   git clone https://github.com/LatticeSemi/hyperram_mc.git
   cd hyperram_mc
   ```

2. **Download and configure the HyperRAM model:**
   - The `testbench/s27ks0641.v` file is a placeholder. You must download the actual model from Infineon:
     1. Visit: https://www.infineon.com/cms/en/product/gated-document/s27kl0641-s27ks0641-verilog-8ac78c8c7d0d8da4017d0f6349a14f68/
     2. Log in or create a free myInfineon account
     3. Download the Verilog model package
     4. Extract and replace `testbench/s27ks0641.v` with the downloaded model
   - **Important:** After replacing the file, edit `testbench/s27ks0641.v` and make the following modifications:

     **Edit 1:** Modify the timing parameter in the specify block:
     ```verilog
     // Find this line:
     specparam  tpd_CK_DQ0               = 1; //tCKD

     // Change it to:
     specparam  tpd_CK_DQ0               = 4500; //tCKD
     ```

     **Edit 2:** Comment out or remove the `$hold` timing check:
     ```verilog
     // Find and comment out this line:
     // $hold (posedge RESETNeg, CSNeg, thold_CSNeg_RESETNeg);
     ```

     **Edit 3:** Comment out or remove the `$skew` timing check:
     ```verilog
     // Find and comment out this line:
     // $skew (negedge CSNeg, posedge CSNeg, tskew_CSNeg_CSNeg, Viol);
     ```

3. **Launch QuestaSim and navigate to the simulation directory:**
   ```bash
   # From QuestaSim GUI or terminal
   cd sim/
   ```

4. **Run the simulation script:**
   ```tcl
   do qsim.do
   ```

   **Note:** After approximately 553ms, the simulation will display "test pass!" indicating successful completion. You must manually terminate the simulation at this point, as it will continue running indefinitely if not stopped.

5. **View the waveforms** in the QuestaSim GUI to analyze the simulation results.

---

### Simulation After IP Regeneration

If you have regenerated the HyperRAM IP using Propel, follow these additional steps to ensure the simulation runs correctly.

**Why this is needed:** When the HyperRAM IP is regenerated, the `DELAY_VALUE` parameter in the PHY module defaults to `"0"`, which needs to be manually adjusted to `"100"` for proper simulation behavior.

**Steps:**

1. **Clone the repository to your local machine:**
   ```bash
   git clone https://github.com/LatticeSemi/hyperram_mc.git
   cd hyperram_mc
   ```

2. **Download and configure the HyperRAM model** (if not already done):
   - Follow Step 2 from the [Standard Simulation Flow](#standard-simulation-flow) to download and configure the `s27ks0641.v` model with the following required modifications:
     - Set `tpd_CK_DQ0 = 4500` timing parameter
     - Comment out the `$hold` timing check for RESETNeg/CSNeg
     - Comment out the `$skew` timing check for CSNeg

3. **Open the Propel project:**
   - Navigate to `example_design/D6_HaperRam/`
   - Open `D6_HaperRam.sbx` with Lattice Propel

4. **Regenerate the HyperRAM IP:**
   - In Propel, double-click on the **HyperRAM block** in the block diagram
   - The IP configuration GUI will open
   - Click **Generate** or **OK** to regenerate the IP

5. **Edit the generated IP file:**
   - Navigate to:
     ```
     example_design/D6_HaperRam/D6_HaperRam/lib/latticesemi.com/ip/hram_controller0/1.0.0/rtl/hram_controller0.v
     ```
   - Open `hram_controller0.v` in a text editor
   - Find the `hram_controller0_ipgen_phy_jedi` module instantiation
   - Locate the `DELAY_VALUE` parameter
   - Change its default value from `"0"` to `"100"`:
     ```verilog
     // Before:
     parameter integer DELAY_VALUE = "0"

     // After:
     parameter integer DELAY_VALUE = "100"
     ```
   - Save the file

6. **Launch QuestaSim and navigate to the simulation directory:**
   ```bash
   cd sim/
   ```

7. **Run the simulation script:**
   ```tcl
   do qsim.do
   ```

   **Note:** After approximately 553ms, the simulation will display "test pass!" indicating successful completion. You must manually terminate the simulation at this point, as it will continue running indefinitely if not stopped.

8. **View the waveforms** to verify correct operation.

---

## Generating Bitstream for Hardware

Follow these steps to synthesize the design and generate a bitstream for FPGA programming.

> **Note:** The current example design is configured for simulation purposes. To ensure proper execution on hardware, verify that the selected device matches your actual hardware target, and that all components are properly regenerated through Propel.

**Steps:**

1. **Clone the repository to your local machine:**
   ```bash
   git clone https://github.com/LatticeSemi/hyperram_mc.git
   cd hyperram_mc
   ```

2. **Open the Propel project:**
   - Navigate to `example_design/D6_HaperRam/`
   - Open `D6_HaperRam.sbx` with Lattice Propel

3. **Generate the Radiant project:**
   - In Propel, click on the **Radiant icon** in the toolbar
   - Propel will automatically generate the Radiant project files
   - Radiant will open automatically with the generated project

4. **Add timing constraints:**
   - In Radiant, go to **File List** view
   - Right-click on **Constraint Files** → **Add** → **Existing File**
   - Navigate to:
     ```
     example_design/D6_HaperRam/source/impl_1/d6.pdc
     ```
   - Select and add the `d6.pdc` constraint file
   - **Note:** Pin location constraints should be added to ensure proper pin assignments for your target FPGA board. Additionally, the I/O bank where the HyperRAM signals are located must be configured with a bank voltage of **1.8V** to match the HyperRAM device requirements.

5. **Begin the bitstream generation flow:**
   - In Radiant, click **Tools** → **Run All** (or press `Ctrl+R`)
   - Alternatively, run the individual steps:
     1. **Synthesis** - Synthesize the RTL design
     2. **Map** - Map the design to FPGA resources
     3. **Place & Route** - Place and route the design
     4. **Generate Bitstream** - Generate the programming file

6. **Locate the generated bitstream:**
   - After successful completion, the bitstream will be located at:
     ```
     example_design/D6_HaperRam/impl_1/D6_HaperRam_impl_1.bit
     ```

7. **Program the FPGA:**
   - Use Lattice Programmer or Radiant's programming tool to download the bitstream to your target FPGA board

---

## Troubleshooting

### Simulation Issues

**Problem:** Simulation fails with compilation errors

**Solution:**
- Ensure all prebuilt libraries are present in `sim/pmi/`, `sim/lfmxo5/`, and `sim/uaplatform/`
- Verify that `sim/bht_ini.bin` exists
- Check that you're using a compatible version of QuestaSim/ModelSim

**Problem:** Simulation runs but behavior is incorrect after IP regeneration

**Solution:**
- Double-check that you've updated the `DELAY_VALUE` parameter from `"0"` to `"100"` in `hram_controller0.v`
- Verify the module name is `hram_controller0_ipgen_phy_jedi`

**Problem:** Simulation behavior is incorrect after downloading the HyperRAM model from Infineon

**Solution:**
- Ensure that the `tpd_CK_DQ0` timing parameter in `testbench/s27ks0641.v` is set to `4500` instead of the default value of `1`
- This parameter controls the clock-to-data output delay and must be adjusted for correct simulation behavior

**Problem:** Simulation reports `$hold` timing violation errors on RESETNeg/CSNeg

**Solution:**
- Comment out or remove the following line in `testbench/s27ks0641.v`:
  ```verilog
  $hold (posedge RESETNeg, CSNeg, thold_CSNeg_RESETNeg);
  ```
- This timing check triggers during simulation initialization when reset and chip select transition simultaneously, which is expected behavior

**Problem:** Simulation reports `$skew` timing violation errors on CSNeg

**Solution:**
- Comment out or remove the following line in `testbench/s27ks0641.v`:
  ```verilog
  $skew (negedge CSNeg, posedge CSNeg, tskew_CSNeg_CSNeg, Viol);
  ```
- This timing check triggers during normal chip select operation and is a model limitation that does not indicate a design problem

---

### Radiant Synthesis Issues

**Problem:** Constraint file not found

**Solution:**
- Ensure the path is correct: `example_design/D6_HaperRam/source/impl_1/d6.pdc`
- If the file is missing, check if it exists in the repository or needs to be created

**Problem:** Synthesis/Place & Route fails with timing violations

**Solution:**
- Review the timing reports in Radiant (`impl_1/*.rpt` files)
- Adjust the constraints in `d6.pdc` if necessary
- Consider relaxing timing constraints or optimizing the design

**Problem:** Radiant project doesn't open automatically

**Solution:**
- Manually navigate to the generated Radiant project directory
- Open the `.rdf` project file in Radiant

---

## Additional Resources

- **Full Documentation:** See [README.md](README.md) for detailed IP documentation
- **IP Metadata:** Review [metadata.xml](metadata.xml) for IP configuration details
- **Bus Interfaces:** See [bus_interface.xml](bus_interface.xml) for AXI interface specifications

---

## Support

For issues, questions, or feature requests, please:
- Check the [README.md](README.md) for detailed documentation
- Review the [doc/introduction.html](doc/introduction.html) for IP-specific details

---

**Quick Reference:**

| Task | Command/Location |
|------|------------------|
| Run Simulation | `cd sim/` → `do qsim.do` |
| Open Propel Project | `example_design/D6_HaperRam/D6_HaperRam.sbx` |
| Edit IP after Regen | `example_design/.../hram_controller0.v` → Change `DELAY_VALUE` to `"100"` |
| Constraint File | `example_design/D6_HaperRam/source/impl_1/d6.pdc` |
| Generated Bitstream | `example_design/D6_HaperRam/impl_1/*.bit` |

