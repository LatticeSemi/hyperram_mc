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
   git clone <TODO: Repository URL will be provided upon release>
   cd hyperram_mc
   ```

2. **Launch QuestaSim and navigate to the simulation directory:**
   ```bash
   # From QuestaSim GUI or terminal
   cd sim/
   ```

3. **Run the simulation script:**
   ```tcl
   do qsim.do
   ```

   **Note:** After approximately 553ms, the simulation will display "test pass!" indicating successful completion. You must manually terminate the simulation at this point, as it will continue running indefinitely if not stopped.

4. **View the waveforms** in the QuestaSim GUI to analyze the simulation results.

---

### Simulation After IP Regeneration

If you have regenerated the HyperRAM IP using Propel, follow these additional steps to ensure the simulation runs correctly.

**Why this is needed:** When the HyperRAM IP is regenerated, the `DELAY_VALUE` parameter in the PHY module defaults to `"0"`, which needs to be manually adjusted to `"100"` for proper simulation behavior.

**Steps:**

1. **Clone the repository to your local machine:**
   ```bash
   git clone <TODO: Repository URL will be provided upon release>
   cd hyperram_mc
   ```

2. **Open the Propel project:**
   - Navigate to `example_design/D6_HaperRam/`
   - Open `D6_HaperRam.sbx` with Lattice Propel

3. **Regenerate the HyperRAM IP:**
   - In Propel, double-click on the **HyperRAM block** in the block diagram
   - The IP configuration GUI will open
   - Click **Generate** or **OK** to regenerate the IP

4. **Edit the generated IP file:**
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

5. **Launch QuestaSim and navigate to the simulation directory:**
   ```bash
   cd sim/
   ```

6. **Run the simulation script:**
   ```tcl
   do qsim.do
   ```

   **Note:** After approximately 553ms, the simulation will display "test pass!" indicating successful completion. You must manually terminate the simulation at this point, as it will continue running indefinitely if not stopped.

7. **View the waveforms** to verify correct operation.

---

## Generating Bitstream for Hardware

Follow these steps to synthesize the design and generate a bitstream for FPGA programming.

**Steps:**

1. **Clone the repository to your local machine:**
   ```bash
   git clone <TODO: Repository URL will be provided upon release>
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
   - **Note:** Pin location constraints should be added to ensure proper pin assignments for your target FPGA board

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
- Contact Lattice Semiconductor support

---

**Quick Reference:**

| Task | Command/Location |
|------|------------------|
| Run Simulation | `cd sim/` → `do qsim.do` |
| Open Propel Project | `example_design/D6_HaperRam/D6_HaperRam.sbx` |
| Edit IP after Regen | `example_design/.../hram_controller0.v` → Change `DELAY_VALUE` to `"100"` |
| Constraint File | `example_design/D6_HaperRam/source/impl_1/d6.pdc` |
| Generated Bitstream | `example_design/D6_HaperRam/impl_1/*.bit` |

