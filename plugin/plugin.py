# =============================================================================
# >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# -----------------------------------------------------------------------------
#   Copyright (c) 2019 by Lattice Semiconductor Corporation
#   ALL RIGHTS RESERVED
# -----------------------------------------------------------------------------
#
#   Permission:
#
#      Lattice SG Pte. Ltd. grants permission to use this code
#      pursuant to the terms of the Lattice Reference Design License Agreement.
#
#
#   Disclaimer:
#
#      This VHDL or Verilog source code is intended as a design reference
#      which illustrates how these types of functions can be implemented.
#      It is the user's responsibility to verify their design for
#      consistency and functionality through the use of formal
#      verification methods.  Lattice provides no warranty
#      regarding the use or functionality of this code.
#
# ------------------------------------------------------------------------------
#
#                  Lattice SG Pte. Ltd.
#                  101 Thomson Road, United Square #07-02
#                  Singapore 307591
#
#
#                  TEL: 1-800-Lattice (USA and Canada)
#                       +65-6631-2000 (Singapore)
#                       +1-503-268-8001 (other locations)
#
#                  web: http://www.latticesemi.com/
#                  email: techsupport@latticesemi.com
#
# ------------------------------------------------------------------------------
#
# ==============================================================================
#                         FILE DETAILS
# Project               : iCE40UP
# File                  : plugin.py
# Title                 :
# Dependencies          : 1.
#                       : 2.
# Description           :
# ==============================================================================
#                        REVISION HISTORY
# Version               : 1.0.0
# Author(s)             :
# Mod. Date             :
# Changes Made          : Initial release.
# ==============================================================================

# ------------------------------------------------------------------------------
# External Functions
# ------------------------------------------------------------------------------

# ==============================================================================
# plugin.py
# ==============================================================================
import os
import string

def get_device_name():
    x = runtime_info.device_info.architecture(1)
    if x in ("LIFCL", "LFD2NX", "LFCPNX","LFMXO5","jd5r00"):
        return "LIFCL"
    elif x in ("LATG1", "LAV-AT"):
        return "LATG1"
    else:
        PluginUtil.post_error("the device is not supported.")
        return x
