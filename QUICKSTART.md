# HyperRAM Memory Controller - Quick Start Guide

This guide provides step-by-step instructions to quickly integrate and use the HyperRAM Memory Controller IP in your design.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [IP Integration](#ip-integration)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before you begin, ensure you have the following tools installed:

- **Lattice Propel** - For SoC integration and IP configuration
- **Lattice Radiant** - For FPGA synthesis and bitstream generation
- **Git** - For cloning the repository

---

## IP Integration

### Using Lattice Propel

1. **Clone the repository to your local machine:**
   ```bash
   git clone https://github.com/LatticeSemi/hyperram_mc.git
   cd hyperram_mc
   ```

2. **Open Lattice Propel** and create a new project or open an existing one.

3. **Add the HyperRAM IP to your design:**
   - In Propel, navigate to the IP catalog
   - Locate the HyperRAM Memory Controller IP
   - Add it to your block diagram

4. **Configure the IP:**
   - Double-click on the HyperRAM block in the block diagram
   - The IP configuration GUI will open
   - Configure parameters as needed (see [Configuration](#configuration) section)
   - Click **Generate** to generate the IP

5. **Connect the IP interfaces:**
   - Connect the AXI4 data interface (`s_axi_*`) to your system bus
   - Connect the AXI4-Lite control interface (`s_axil_*`) to your control bus
   - Connect the HyperBus physical interface to your HyperRAM device

6. **Generate the Radiant project:**
   - In Propel, click on the **Radiant icon** in the toolbar
   - Propel will automatically generate the Radiant project files
   - Radiant will open automatically with the generated project

---

## Configuration

### IP Parameters

The HyperRAM Memory Controller IP supports the following key parameters:

- **FAMILY** - Target FPGA family (default: "LIFCL")
- **HYPERRAM_NUM** - Number of HyperRAM devices (1 or 2, default: 2)
- **ONE_RANK_EN** - Single rank enable (default: 1)
- **ID_W** - AXI ID width (default: 1)
- **INITIAL_LATENCY** - Initial latency configuration (default: 0)
- **DELAY_HALF_CYCLE** - Half cycle delay enable (default: 0)
- **SYSBUS_CLOCK_MHZ** - System bus clock frequency in MHz (default: 150)
- **TVCS_10US** - Timing parameter for 10μs in clock cycles (default: 15)

### Clock Configuration

The IP requires the following clock inputs:

- **System Clock (`clk_i`)** - Configurable via `SYSBUS_CLOCK_MHZ` parameter
- **HyperBus Clock (`hyperbus_clk_i`)** - Main HyperBus clock
- **HyperBus Clock 270° (`hyperbus_clk270_i`)** - Phase-shifted clock for data capture

**Typical Configuration:**
- System clock: 150 MHz
- HyperBus clock: 200 MHz (requires phase-shifted version)

### Timing Constraints

When using the IP in your design, ensure you add appropriate timing constraints:

- Clock definitions for all clock domains
- Input/output delay constraints for HyperBus interface
- False paths for asynchronous resets
- Multi-cycle paths if applicable

---

## Troubleshooting

### Integration Issues

**Problem:** IP doesn't appear in Propel IP catalog

**Solution:**
- Ensure the IP repository path is correctly configured in Propel
- Verify that `metadata.xml` and `plugin/` directory are present
- Check Propel version compatibility

**Problem:** Synthesis fails with compilation errors

**Solution:**
- Verify all RTL files are included in the project
- Check that the target FPGA family matches the IP configuration
- Ensure all required Lattice primitives are available for your device

**Problem:** Timing violations in HyperBus interface

**Solution:**
- Review timing reports to identify failing paths
- Verify clock relationships and phase alignment
- Adjust timing constraints if necessary
- Consider using different clock frequencies or gearing ratios

**Problem:** HyperRAM device not responding

**Solution:**
- Verify HyperBus physical connections (clock, data, control signals)
- Check that device power-up sequence is correct
- Verify reset timing and initialization sequence
- Review register configuration (see Register Map in README.md)

---

## Additional Resources

- **Full Documentation:** See [README.md](README.md) for detailed IP documentation
- **IP Metadata:** Review [metadata.xml](metadata.xml) for IP configuration details
- **Bus Interfaces:** See [bus_interface.xml](bus_interface.xml) for AXI interface specifications
- **Memory Map:** See [memory_map.xml](memory_map.xml) for register and memory space definitions

---

## Support

For issues, questions, or feature requests, please:
- Check the [README.md](README.md) for detailed documentation
- Review the [doc/introduction.html](doc/introduction.html) for IP-specific details
- Contact Lattice Semiconductor support

---

**Quick Reference:**

| Task | Description |
|------|-------------|
| Add IP to Design | Use Propel IP catalog to add HyperRAM Memory Controller |
| Configure IP | Double-click IP block → Configure parameters → Generate |
| Generate Project | Click Radiant icon in Propel toolbar |
| View Documentation | See [README.md](README.md) and [doc/introduction.html](doc/introduction.html) |

