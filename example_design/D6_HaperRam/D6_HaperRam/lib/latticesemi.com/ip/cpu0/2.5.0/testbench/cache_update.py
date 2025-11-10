# =============================================================================
# >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# -----------------------------------------------------------------------------
#   Copyright (c) 2018 by Lattice Semiconductor Corporation
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
# Project               : 
# File                  : cache_update.py
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
import os
import sys
import re


def yaml_update():
    insPath         = os.path.realpath(os.path.join(os.path.dirname(os.path.realpath(__file__)),".."))
    tbPath          = os.path.realpath(os.path.join(insPath,"testbench")) 
    cpu_yaml_file   = os.path.realpath(os.path.join(tbPath,"cpu0.yaml")) 

    cache_contents = [r'iBus: !!vexriscv.BusReport', r'  flushInstructions: [4111, 19, 19, 19]', r'  info: !!vexriscv.CacheReport {bytePerLine: 32, size: 4096}',  r'  kind: cached']
    if(os.environ['cpu_cache'] == 'enabled'):
        with open(cpu_yaml_file, 'a') as file1:
            #print(file1.readlines())
            for line in cache_contents:
                file1.write(line + '\n')

yaml_update()