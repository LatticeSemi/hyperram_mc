# HyperRAM Memory Controller

FPGA IP core for HyperRAM memory controller implementation.

## Overview

This repository contains a memory controller IP for HyperRAM devices with AXI4 interface support.

## Features

- AXI4 interface support (32-bit data)
- AXI4-Lite control interface (32-bit)
- HyperBus protocol controller
- PHY interface for FPGA implementation (ODDRX1/IDDRX1)
- Configurable address space
- Dual channel support (2x8 or 1x16 configuration)
- 2:1 gearing ratio
- Maximum frequency: 225.5 MHz

## Target Device Specifications

| Parameter | Value |
|-----------|-------|
| **FPGA Family** | Nexus |
| **Target Device** | LFMXO5-65T-8BBG484C |
| **Device Speed Grade** | 8 |
| **Package** | BBG484C |
| **I/O Pins** | 20 |

## HyperRAM Specifications

### Supported Standards

| Standard | Speed | Data Width | Status |
|----------|-------|------------|--------|
| HyperRAM 1.0 | 333 Mbps | x8 | ✓ Supported |
| HyperRAM 2.0 | 400 Mbps | x8 | ✓ Supported |
| HyperRAM 3.0 | 800 Mbps | x16 (max clk 400MHz) | ✗ Not supported |

### Memory Configuration

| Parameter | Value |
|-----------|-------|
| **Number of Ranks** | Single rank |
| **Number of Channels** | 2 (configurable: 2×8 or 1×16) |
| **Gearing Ratio** | 2:1 |
| **Interface Type** | AXI4 32-bit (data) + AXI4-Lite 32-bit (control) |

### Clock Configuration

| Clock | Frequency | Description |
|-------|-----------|-------------|
| **eclk** | 200 MHz | External/HyperBus clock |
| **sclk** | 50 MHz | System clock |
| **Maximum Frequency** | 225.5 MHz | Maximum achievable system frequency |

## Resource Utilization

| Resource | Count |
|----------|-------|
| **LUTs** | 602 |
| **Registers (REG)** | 749 |
| **EBR (Block RAM)** | 3 |

**Total I/O:** 20 pins

## Tool Support

| Tool | Supported | Notes |
|------|-----------|-------|
| **Radiant** | ✓ Yes | FPGA synthesis and implementation |
| **Propel** | ✓ Yes | SoC integration |
| **Driver** | N/A | - |

## Validation Status

| Test Type | Status | Details |
|-----------|--------|---------|
| **RTL Simulation** | ✓ Passed | Functional verification complete |
| **Hardware Testing** | ✓ Passed | Validated on LFMXO5-65T-EVN |
| **STA Timing** | ✓ Met | Static timing analysis passed |

**Test Board:** LFMXO5-65T-EVN

## Directory Structure

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

## RTL Files

- `hyperram_mc.v` - Top-level memory controller
- `hyperbus_controller.v` - HyperBus protocol controller
- `axi2local.v` - AXI to local bus bridge
- `axil_if.v` - AXI4-Lite interface
- `phy_jedi.v` - PHY interface
- `sync_non_rst.v` - Synchronizer for clock domain crossing

## Getting Started

### Prerequisites

- **Radiant** - FPGA synthesis and implementation tool
- **Propel** - SoC builder and integration tool
- Simulation tools (Questasim, Modelsim, etc.)

### Integration

Integrate the HyperRAM controller into your design by instantiating the top-level module.

## Module Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| FAMILY | "LIFCL" | Target FPGA family |
| HYPERRAM_NUM | 2 | Number of HyperRAM devices (1 or 2) |
| ONE_RANK_EN | 1 | Single rank enable |
| ID_W | 1 | AXI ID width |
| INITIAL_LATENCY | 0 | Initial latency configuration |
| DELAY_HALF_CYCLE | 0 | Half cycle delay enable |
| SYSBUS_CLOCK_MHZ | 150 | System bus clock frequency in MHz |
| TVCS_10US | 15 | Timing parameter (10μs in clock cycles) |

## Clocks and Resets

### Clock Inputs

| Signal | Type | Description |
|--------|------|-------------|
| `clk_i` | Input | System clock (e.g., 150 MHz) |
| `hyperbus_clk_i` | Input | HyperBus clock (main) |
| `hyperbus_clk270_i` | Input | HyperBus clock 270° phase shifted |

**Clock Requirements:**
- System clock (`clk_i`): Configurable via `SYSBUS_CLOCK_MHZ` parameter
- HyperBus clocks: Requires phase-shifted clocks for proper data capture
- Typical configuration: 150 MHz system clock

### Reset

| Signal | Type | Polarity | Description |
|--------|------|----------|-------------|
| `rst_n` | Input | Active Low | Asynchronous reset for entire module |

**Reset Behavior:**
- Active low reset
- Resets all internal state machines and registers
- HyperRAM devices are reset via `hyperbus_resetn_o`

## Port Descriptions

### HyperBus Physical Interface

| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| `hyperbus_clk_o` | [HYPERRAM_NUM-1:0] | Output | HyperBus differential clock (positive) |
| `hyperbus_clkn_o` | [HYPERRAM_NUM-1:0] | Output | HyperBus differential clock (negative) |
| `hyperbus_csn_o` | [HYPERRAM_NUM-1:0] | Output | Chip select, active low |
| `hyperbus_resetn_o` | [HYPERRAM_NUM-1:0] | Output | HyperRAM device reset, active low |
| `hyperbus_rwds_io` | [HYPERRAM_NUM-1:0] | Inout | Read/Write Data Strobe (bidirectional) |
| `hyperbus_dq_io` | [8*HYPERRAM_NUM-1:0] | Inout | Data bus (8 bits per device) |

### AXI4-Lite Control Interface

**Write Address Channel:**
| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| `s_axil_awvalid` | 1 | Input | Write address valid |
| `s_axil_awready` | 1 | Output | Write address ready |
| `s_axil_awaddr` | 32 | Input | Write address |
| `s_axil_awprot` | 3 | Input | Protection type |

**Write Data Channel:**
| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| `s_axil_wvalid` | 1 | Input | Write data valid |
| `s_axil_wready` | 1 | Output | Write data ready |
| `s_axil_wdata` | 32 | Input | Write data |
| `s_axil_wstrb` | 4 | Input | Write strobes |

**Write Response Channel:**
| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| `s_axil_bvalid` | 1 | Output | Write response valid |
| `s_axil_bready` | 1 | Input | Write response ready |
| `s_axil_bresp` | 2 | Output | Write response |

**Read Address Channel:**
| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| `s_axil_arvalid` | 1 | Input | Read address valid |
| `s_axil_arready` | 1 | Output | Read address ready |
| `s_axil_araddr` | 32 | Input | Read address |
| `s_axil_arprot` | 3 | Input | Protection type |

**Read Data Channel:**
| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| `s_axil_rvalid` | 1 | Output | Read data valid |
| `s_axil_rready` | 1 | Input | Read data ready |
| `s_axil_rdata` | 32 | Output | Read data |
| `s_axil_rresp` | 2 | Output | Read response |

### AXI4 Data Interface

**Write Address Channel:**
| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| `s_axi_awvalid` | 1 | Input | Write address valid |
| `s_axi_awready` | 1 | Output | Write address ready |
| `s_axi_awid` | ID_W | Input | Write address ID |
| `s_axi_awaddr` | 32 | Input | Write address |
| `s_axi_awlen` | 8 | Input | Burst length |
| `s_axi_awsize` | 3 | Input | Burst size |
| `s_axi_awburst` | 2 | Input | Burst type |
| `s_axi_awlock` | 1 | Input | Lock type |
| `s_axi_awcache` | 4 | Input | Cache type |
| `s_axi_awprot` | 3 | Input | Protection type |
| `s_axi_awqos` | 4 | Input | Quality of service |

**Write Data Channel:**
| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| `s_axi_wvalid` | 1 | Input | Write data valid |
| `s_axi_wready` | 1 | Output | Write data ready |
| `s_axi_wdata` | 32 | Input | Write data |
| `s_axi_wstrb` | 4 | Input | Write strobes |
| `s_axi_wlast` | 1 | Input | Write last |

**Write Response Channel:**
| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| `s_axi_bvalid` | 1 | Output | Write response valid |
| `s_axi_bready` | 1 | Input | Write response ready |
| `s_axi_bid` | ID_W | Output | Response ID |
| `s_axi_bresp` | 2 | Output | Write response |

**Read Address Channel:**
| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| `s_axi_arvalid` | 1 | Input | Read address valid |
| `s_axi_arready` | 1 | Output | Read address ready |
| `s_axi_arid` | ID_W | Input | Read address ID |
| `s_axi_araddr` | 32 | Input | Read address |
| `s_axi_arlen` | 8 | Input | Burst length |
| `s_axi_arsize` | 3 | Input | Burst size |
| `s_axi_arburst` | 2 | Input | Burst type |
| `s_axi_arlock` | 1 | Input | Lock type |
| `s_axi_arcache` | 4 | Input | Cache type |
| `s_axi_arprot` | 3 | Input | Protection type |
| `s_axi_arqos` | 4 | Input | Quality of service |

**Read Data Channel:**
| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| `s_axi_rvalid` | 1 | Output | Read data valid |
| `s_axi_rready` | 1 | Input | Read data ready |
| `s_axi_rid` | ID_W | Output | Read ID |
| `s_axi_rdata` | 32 | Output | Read data |
| `s_axi_rlast` | 1 | Output | Read last |
| `s_axi_rresp` | 2 | Output | Read response |

**User Signals:**
| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| `s_axi_awuser` | 1 | Input | Write address user signal |
| `s_axi_wuser` | 1 | Input | Write data user signal |
| `s_axi_buser` | 1 | Output | Write response user signal |
| `s_axi_aruser` | 1 | Input | Read address user signal |
| `s_axi_ruser` | 1 | Output | Read data user signal |

### Interrupt

| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| `intr_o` | 1 | Output | Interrupt request, active high |

## Register Map

### Control Register Space (AXI-Lite Interface)

**Base Address:** 0x0000
**Address Range:** 4 KB (0x0000 - 0x0FFF)
**Data Width:** 32 bits

The control registers are accessed via the AXI4-Lite interface (`s_axil_*` ports) and provide configuration and status monitoring capabilities.

| Offset | Register Name | Access | Description |
|--------|---------------|--------|-------------|
| 0x00 | CSR | R | Controller Status Register |
| 0x04 | MBAR0 | R/W | CS0 Memory Base Address Register |
| 0x08 | MBAR1 | R/W | CS1 Memory Base Address Register |
| 0x0C | MCR0 | R/W | CS0 Memory Configuration Register |
| 0x10 | MCR1 | R/W | CS1 Memory Configuration Register |
| 0x14 | MTR | R/W | Memory Timing Register |
| 0x18 | MTR_EXT | R/W | Memory Timing Extended Register |
| 0x1C | CCR | R/W | Controller Configuration Register |
| 0x20 | DPCR | R/W | Data Path Calibration Register |

### Register Bit Definitions

#### 0x00 - CSR (Controller Status Register) - Read Only

| Bits | Name | Type | Description |
|------|------|------|-------------|
| [31:27] | Reserved | R | Reserved (reads as 0) |
| [26] | WRSTOERR | R | Write transaction RSTO error |
| [25] | WTRSERR | R | Write transaction AXI protocol error |
| [24] | WDECERR | R | Write transaction address decode error |
| [23:17] | Reserved | R | Reserved (reads as 0) |
| [16] | WACT | R | Write transaction active |
| [15:12] | Reserved | R | Reserved (reads as 0) |
| [11] | RDSSTALL | R | Read transaction RDS stall error |
| [10] | RRSTOERR | R | Read transaction RSTO error |
| [9] | RTRSERR | R | Read transaction AXI protocol error |
| [8] | RDECERR | R | Read transaction address decode error |
| [7] | RSAMPERR | R | Read transaction RWDS sampling error |
| [6:1] | Reserved | R | Reserved (reads as 0) |
| [0] | RACT | R | Read transaction active |

#### 0x04 - MBAR0 (CS0 Memory Base Address Register)

| Bits | Name | Type | Description |
|------|------|------|-------------|
| [31:24] | OFFSET | R/W | Memory base address offset (upper 8 bits) |
| [23:0] | Reserved | R | Reserved (reads as 0) |

#### 0x08 - MBAR1 (CS1 Memory Base Address Register)

| Bits | Name | Type | Description |
|------|------|------|-------------|
| [31:24] | OFFSET | R/W | Memory base address offset (upper 8 bits) |
| [23:0] | Reserved | R | Reserved (reads as 0) |

#### 0x0C - MCR0 (CS0 Memory Configuration Register)

| Bits | Name | Type | Description |
|------|------|------|-------------|
| [31] | MAXEN | R/W | Maximum burst length enable |
| [30:27] | Reserved | R | Reserved (reads as 0) |
| [26:18] | MAXLEN | R/W | Maximum burst length (9 bits) |
| [17:6] | Reserved | R | Reserved (reads as 0) |
| [5] | CRT | R | Memory/Register space selection (CA[46]) |
| [4] | DEVTYPE | R/W | Device type (0=HyperRAM, 1=HyperFlash) |
| [3:0] | Reserved | R | Reserved (reads as 0) |

#### 0x10 - MCR1 (CS1 Memory Configuration Register)

| Bits | Name | Type | Description |
|------|------|------|-------------|
| [31] | MAXEN | R/W | Maximum burst length enable |
| [30:27] | Reserved | R | Reserved (reads as 0) |
| [26:18] | MAXLEN | R/W | Maximum burst length (9 bits) |
| [17:6] | Reserved | R | Reserved (reads as 0) |
| [5] | CRT | R | Memory/Register space selection (CA[46]) |
| [4] | DEVTYPE | R/W | Device type (0=HyperRAM, 1=HyperFlash) |
| [3:0] | Reserved | R | Reserved (reads as 0) |

#### 0x14 - MTR (Memory Timing Register)

| Bits | Name | Type | Description |
|------|------|------|-------------|
| [31:28] | RCSHI | R/W | Read CS# high time |
| [27:24] | WCSHI | R/W | Write CS# high time |
| [23:20] | RCSS | R/W | Read CS# setup time |
| [19:16] | WCSS | R/W | Write CS# setup time |
| [15:12] | RCSH | R/W | Read CS# hold time |
| [11:8] | WCSH | R/W | Write CS# hold time |
| [7:4] | Reserved | R | Reserved (reads as 0) |
| [3:0] | LATENCY | R/W | Initial latency configuration |

#### 0x18 - MTR_EXT (Memory Timing Extended Register)

| Bits | Name | Type | Description |
|------|------|------|-------------|
| [31:16] | TVCS | R/W | Power-up reset time (in clock cycles) |
| [15:14] | TDSV | R/W | Data setup time |
| [13:12] | TDSZ | R/W | Data hold time |
| [11:10] | TOZ | R/W | Output disable time |
| [9:8] | TCSM | R/W | CS# maximum time |
| [7:6] | TRWR | R/W | Read-Write-Read delay |
| [5:0] | Reserved | R | Reserved (reads as 0) |

**Reset Value:** TVCS field defaults to TVCS_10US parameter value (typically 160 for 150MHz clock)

#### 0x1C - CCR (Controller Configuration Register)

| Bits | Name | Type | Description |
|------|------|------|-------------|
| [31:30] | RAM_SIZE | R/W | HyperRAM size configuration |
| [29:28] | MODE | R/W | Operating mode selection |
| [27] | DYNAMIC_LATENCY_EN | R/W | Dynamic latency enable |
| [26:0] | Reserved | R | Reserved (reads as 0) |

#### 0x20 - DPCR (Data Path Calibration Register)

| Bits | Name | Type | Description |
|------|------|------|-------------|
| [31:24] | DQ_BIT_SEL | R/W | DQ bit select for calibration |
| [23] | DIR | R/W | Direction control |
| [22] | LOADN | R/W | Load enable (active low) |
| [21:20] | COARSE | R/W | Coarse delay adjustment |
| [19:0] | Reserved | R | Reserved (reads as 0) |

### Data Memory Space (AXI4 Interface)

**Base Address:** 0x0000_0000
**Address Range:** 16 MB (0x0000_0000 - 0x00FF_FFFF)
**Data Width:** 32 bits

The data memory space is accessed via the AXI4 interface (`s_axi_*` ports) and provides direct access to the HyperRAM memory.

**Address Mapping:**
- **Device 0:** Lower half of address space
- **Device 1:** Upper half of address space (when HYPERRAM_NUM = 2)

**Supported Transaction Types:**
- Burst reads (up to 256 beats)
- Burst writes (up to 256 beats)
- Single transfers
- Wrap bursts

## Configuration

Configuration parameters are available through:
- `memory_map.xml` - Memory map definitions
- `bus_interface.xml` - Bus interface configuration

## Documentation

See the `doc/` directory for detailed documentation.

## License

[Specify your license here]

## Version

v1.0.0

